import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/image_compressor.dart';

export '../utils/image_compressor.dart';

/// Servicio para la selección, compresión de alta calidad y almacenamiento en la nube
/// de imágenes (Firebase Cloud Storage).
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FirebaseStorage get _storage => FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Permite al usuario capturar una foto o seleccionarla de la galería.
  ///
  /// Aplica compresión de alta fidelidad (no agresiva) según [preset]:
  /// - `ImageCompressionPreset.postAndReport`: máx. 1600 px, calidad 85%.
  /// - `ImageCompressionPreset.avatar`: máx. 800 px, calidad 85%.
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    ImageCompressionPreset preset = ImageCompressionPreset.postAndReport,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final effectiveQuality = imageQuality ?? preset.quality;
      final effectiveMaxWidth = maxWidth ?? preset.maxDimension.toDouble();
      final effectiveMaxHeight = maxHeight ?? preset.maxDimension.toDouble();

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: effectiveQuality,
        maxWidth: effectiveMaxWidth,
        maxHeight: effectiveMaxHeight,
      );

      if (pickedFile == null) return null;

      final rawFile = File(pickedFile.path);
      return await ImageCompressor.compressFile(
        rawFile,
        preset: preset,
      );
    } catch (e) {
      throw Exception('No se pudo seleccionar la imagen: $e');
    }
  }

  /// Comprime (si aún no está optimizada) y sube una imagen a Firebase Storage,
  /// retornando la URL pública de descarga.
  ///
  /// - [folder]: Carpeta en el bucket (ej.: `'community_posts'`, `'reports'`, `'mating_posts'`, `'avatars'`).
  /// - [file]: Archivo local a subir.
  /// - [preset]: Perfil de compresión opcional (si se omite, se infiere automáticamente según [folder]).
  /// - [customFileName]: Nombre específico opcional; por defecto genera un nombre único `.jpg`.
  Future<String> uploadImage({
    required File file,
    required String folder,
    ImageCompressionPreset? preset,
    String? customFileName,
  }) async {
    try {
      final effectivePreset = preset ?? ImageCompressor.presetForFolder(folder);
      final optimizedFile = await ImageCompressor.compressFile(
        file,
        preset: effectivePreset,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'public';
      final baseName = optimizedFile.path
          .split(Platform.pathSeparator)
          .last
          .replaceAll(RegExp(r'\.[^.]+$'), '');
      final fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_$baseName.jpg';

      final ref = _storage.ref().child('$folder/$userId/$fileName');

      final uploadTask = ref.putFile(
        optimizedFile,
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
