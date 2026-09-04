import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Flujo reactivo del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario autenticado actualmente
  User? get currentUser => _auth.currentUser;

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

    if (credential.user != null && displayName.trim().isNotEmpty) {
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();
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
