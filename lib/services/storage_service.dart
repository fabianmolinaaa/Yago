import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para la selección, compresión y almacenamiento en la nube de imágenes (Firebase Storage)
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FirebaseStorage get _storage => FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Permite al usuario capturar una foto o seleccionarla de la galería.
  /// Incluye compresión de dimensiones y calidad para optimizar almacenamiento y red.
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
    double maxWidth = 1280,
    double maxHeight = 1280,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('No se pudo seleccionar la imagen: $e');
    }
  }

  /// Sube un archivo a Firebase Storage y retorna la URL pública de descarga.
  ///
  /// - [folder]: Carpeta en el bucket (ej.: 'posts', 'reports', 'avatars').
  /// - [file]: Archivo local a subir.
  /// - [customFileName]: Nombre específico opcional; por defecto genera un nombre temporal único.
  Future<String> uploadImage({
    required File file,
    required String folder,
    String? customFileName,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'public';
      final fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';

      final ref = _storage.ref().child('$folder/$userId/$fileName');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Error de Firebase Storage (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al subir la imagen: $e');
    }
  }

  /// Elimina un archivo de Firebase Storage a partir de su URL pública.
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      // Si el archivo ya no existe, no arroja excepción crítica
      if (e.code != 'object-not-found') {
        throw Exception('Error al eliminar la imagen: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado al eliminar la imagen: $e');
    }
  }
}
