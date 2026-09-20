import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'mock_data_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Flujo reactivo del estado de autenticación
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Usuario autenticado actualmente (seguro ante tests o entornos sin Firebase inicializado)
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Inicia sesión con correo y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registra una nueva cuenta de usuario
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      final name = displayName.trim();
      if (name.isNotEmpty) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }

      // Persistir documento inicial limpio en Cloud Firestore (/users/{uid})
      try {
        final newUser = UserModel(
          uid: credential.user!.uid,
          email: email.trim(),
          displayName: name,
          photoUrl: null,
          phoneNumber: '',
          bio: '',
          location: '',
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await FirestoreService().setUserProfile(newUser);
      } catch (_) {}
    }

    return credential;
  }

  /// Envía correo para restablecer contraseña
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Cierra la sesión activa
  Future<void> signOut() async {
    await _auth.signOut();
    MockDataService().clearUserProfileCache();
  }

  /// Actualiza el perfil del usuario autenticado (nombre y/o foto)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser != null) {
        if (displayName != null && displayName.trim().isNotEmpty) {
          await _auth.currentUser!.updateDisplayName(displayName.trim());
        }
        if (photoURL != null && photoURL.trim().isNotEmpty) {
          await _auth.currentUser!.updatePhotoURL(photoURL.trim());
        }
        await _auth.currentUser!.reload();

        // Actualizar en Firestore
        final uid = _auth.currentUser!.uid;
        final Map<String, dynamic> updateData = {};
        if (displayName != null) updateData['displayName'] = displayName.trim();
        if (photoURL != null) updateData['photoUrl'] = photoURL.trim();
        if (updateData.isNotEmpty) {
          await FirestoreService().updateUserProfile(uid, updateData);
        }
      }
    } catch (_) {}
  }

  /// Traduce excepciones de Firebase Auth a mensajes amigables en español
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta registrada con este correo electrónico.';
        case 'wrong-password':
          return 'Contraseña incorrecta. Por favor verifícala.';
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos. Verifica tus datos.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con este correo electrónico. Inicia sesión.';
        case 'weak-password':
          return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
        case 'invalid-email':
          return 'El formato del correo electrónico no es válido.';
        case 'user-disabled':
          return 'Esta cuenta ha sido inhabilitada. Contacta al soporte.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta de nuevo más tarde.';
        case 'network-request-failed':
          return 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
        case 'operation-not-allowed':
          return 'El inicio de sesión con correo y contraseña no está habilitado en Firebase.';
        default:
          return error.message ?? 'Ocurrió un error inesperado al autenticar.';
      }
    }
    return error?.toString() ?? 'Ocurrió un error inesperado.';
  }
}
