import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Perfiles de compresión de imágenes calibrados para Yago.
///
/// Diseñados bajo una política de **alta fidelidad visual (no agresiva)** que
/// preserva la nitidez de pelaje, ojos, manchas, collares y señas particulares,
/// reduciendo entre un 80% y un 92% el peso de las fotografías crudas de cámara.
enum ImageCompressionPreset {
  /// Publicaciones comunitarias, reportes de mascotas perdidas/encontradas,
  /// avisos de apareamiento y capturas de la Cámara IA.
  /// - Resolución máxima: 1600 px (Full HD+ proporcional)
  /// - Calidad JPEG: 85%
  /// - Omisión inteligente si ya es JPEG <= 350 KB
  postAndReport(
    maxDimension: 1600,
    quality: 85,
    smartSkipThresholdBytes: 350 * 1024,
  ),

  /// Fotografías de perfil / avatares de usuario.
  /// - Resolución máxima: 800 px (Retina 3x para avatares circulares)
  /// - Calidad JPEG: 85%
  /// - Omisión inteligente si ya es JPEG <= 150 KB
  avatar(
    maxDimension: 800,
    quality: 85,
    smartSkipThresholdBytes: 150 * 1024,
  ),

  /// Payload optimizado para inferencia multimodal en la nube (Cámara IA).
  /// - Resolución máxima: 1024 px
  /// - Calidad JPEG: 82%
  /// - Omisión inteligente si ya es JPEG <= 300 KB
  aiCloudPayload(
    maxDimension: 1024,
    quality: 82,
    smartSkipThresholdBytes: 300 * 1024,
  );

  final int maxDimension;
  final int quality;
  final int smartSkipThresholdBytes;

  const ImageCompressionPreset({
    required this.maxDimension,
    required this.quality,
    required this.smartSkipThresholdBytes,
  });
}

/// Resultado detallado del proceso de compresión de una imagen.
class ImageCompressionStats {
  final File file;
  final int originalBytes;
  final int compressedBytes;
  final bool wasCompressed;

  const ImageCompressionStats({
    required this.file,
    required this.originalBytes,
    required this.compressedBytes,
    required this.wasCompressed,
  });

  /// Porcentaje de ahorro de tamaño logrado (0.0 a 100.0).
  double get savedPercentage {
    if (originalBytes <= 0 || compressedBytes >= originalBytes) return 0.0;
    return ((originalBytes - compressedBytes) / originalBytes) * 100.0;
  }
}

/// Motor centralizado de compresión y optimización de imágenes de Yago.
///
/// Aplica compresión no agresiva de alta calidad en todos los módulos donde
/// el usuario selecciona o captura imágenes (Reportes, Publicaciones del Feed,
/// Edición de Perfil y Cámara con IA).
class ImageCompressor {
  ImageCompressor._();

  /// Determina el perfil de compresión ideal según la carpeta de destino en Storage.
  static ImageCompressionPreset presetForFolder(String folder) {
    final normalized = folder.trim().toLowerCase();
    if (normalized.contains('avatar') || normalized.contains('profile')) {
      return ImageCompressionPreset.avatar;
    }
    return ImageCompressionPreset.postAndReport;
  }

  /// Verifica si el archivo ya tiene extensión JPEG.
  static bool _isJpegPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg');
  }

  /// Comprime un archivo de imagen local aplicando el [preset] indicado.
  ///
  /// 1. Si el archivo ya es JPEG y pesa menos que `preset.smartSkipThresholdBytes`,
  ///    comprueba sus dimensiones y evita recomprimirlo innecesariamente para
  ///    prevenir pérdida generacional de calidad.
  /// 2. Utiliza aceleración nativa por hardware (`FlutterImageCompress`) con
  ///    corrección automática de rotación EXIF (`autoCorrectionAngle: true`) y
  ///    limpieza de metadatos sensibles (`keepExif: false`).
  /// 3. Incluye guardia de tamaño (*Size Guard*): si el archivo resultante
  ///    llegara a pesar igual o más que el original (y el original ya es JPEG),
  ///    conserva el archivo original.
  static Future<File> compressFile(
    File file, {
    ImageCompressionPreset preset = ImageCompressionPreset.postAndReport,
  }) async {
    final stats = await compressFileWithStats(file, preset: preset);
    return stats.file;
  }

  /// Versión extendida de [compressFile] que devuelve estadísticas de ahorro.
  static Future<ImageCompressionStats> compressFileWithStats(
    File file, {
    ImageCompressionPreset preset = ImageCompressionPreset.postAndReport,
  }) async {
    if (!await file.exists()) {
      return ImageCompressionStats(
        file: file,
        originalBytes: 0,
        compressedBytes: 0,
        wasCompressed: false,
      );
    }

    final int originalLength = await file.length();
    if (originalLength <= 0) {
      return ImageCompressionStats(
        file: file,
        originalBytes: 0,
        compressedBytes: 0,
        wasCompressed: false,
      );
    }

    final bool isJpeg = _isJpegPath(file.path);

    // 1. Omisión inteligente (Smart Skip): si ya es un JPEG liviano dentro del umbral
    if (isJpeg && originalLength <= preset.smartSkipThresholdBytes) {
      final withinBounds = await _isImageWithinDimension(
        file,
        preset.maxDimension,
      );
      if (withinBounds) {
        return ImageCompressionStats(
          file: file,
          originalBytes: originalLength,
          compressedBytes: originalLength,
          wasCompressed: false,
        );
      }
    }

    // 2. Compresión nativa acelerada por hardware (Android / iOS / macOS)
    try {
      final targetPath = _buildCompressedTargetPath(file.path);
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: preset.maxDimension,
        minHeight: preset.maxDimension,
        quality: preset.quality,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: false,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        if (await compressedFile.exists()) {
          final compressedLength = await compressedFile.length();
          // Guardia de no-inflado: si ya era JPEG y el resultado no redujo tamaño
          // (y estaba dentro de las dimensiones máximas), conservar original.
          if (compressedLength > 0 &&
              (!isJpeg || compressedLength < originalLength)) {
            return ImageCompressionStats(
              file: compressedFile,
              originalBytes: originalLength,
              compressedBytes: compressedLength,
              wasCompressed: true,
            );
          } else if (compressedLength >= originalLength && isJpeg) {
            final withinBounds = await _isImageWithinDimension(
              file,
              preset.maxDimension,
            );
            if (withinBounds) {
              return ImageCompressionStats(
                file: file,
                originalBytes: originalLength,
                compressedBytes: originalLength,
                wasCompressed: false,
              );
            }
            return ImageCompressionStats(
              file: compressedFile,
              originalBytes: originalLength,
              compressedBytes: compressedLength,
              wasCompressed: true,
            );
          }
        }
      }
    } catch (_) {
      // Fallback en caso de entorno de test o plataforma sin canal nativo
    }

    // 3. Fallback en memoria para redimensionar imágenes grandes si el plugin nativo no está activo
    if (originalLength > preset.smartSkipThresholdBytes) {
      try {
        final rawBytes = await file.readAsBytes();
        final fallbackBytes = await compressBytes(
          rawBytes,
          preset: preset,
        );
        if (fallbackBytes.isNotEmpty && fallbackBytes.length < originalLength) {
          final targetFile = File(_buildCompressedTargetPath(file.path));
          await targetFile.writeAsBytes(fallbackBytes, flush: true);
          return ImageCompressionStats(
            file: targetFile,
            originalBytes: originalLength,
            compressedBytes: fallbackBytes.length,
            wasCompressed: true,
          );
        }
      } catch (_) {}
    }

    return ImageCompressionStats(
      file: file,
      originalBytes: originalLength,
      compressedBytes: originalLength,
      wasCompressed: false,
    );
  }

  /// Comprime un arreglo de bytes de imagen en memoria aplicando [preset].
  static Future<Uint8List> compressBytes(
    Uint8List rawBytes, {
    ImageCompressionPreset preset = ImageCompressionPreset.postAndReport,
  }) async {
    if (rawBytes.isEmpty) return rawBytes;

    // 1. Intentar compresión nativa JPEG en memoria
    try {
      final result = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: preset.maxDimension,
        minHeight: preset.maxDimension,
        quality: preset.quality,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: false,
      );
      if (result.isNotEmpty && result.length < rawBytes.length) {
        return result;
      }
    } catch (_) {}

    // 2. Fallback con codec nativo de Flutter (dart:ui) si supera el umbral
    if (rawBytes.length > preset.smartSkipThresholdBytes) {
      try {
        final probeCodec = await ui.instantiateImageCodec(rawBytes);
        final probeFrame = await probeCodec.getNextFrame();
        final origW = probeFrame.image.width;
        final origH = probeFrame.image.height;
        probeFrame.image.dispose();

        final maxDim = origW > origH ? origW : origH;
        final int targetW;
        final int targetH;
        if (maxDim > preset.maxDimension) {
          final scale = preset.maxDimension / maxDim;
          targetW = (origW * scale).round().clamp(1, preset.maxDimension);
          targetH = (origH * scale).round().clamp(1, preset.maxDimension);
        } else {
          targetW = origW;
          targetH = origH;
        }

        final resizedCodec = await ui.instantiateImageCodec(
          rawBytes,
          targetWidth: targetW,
          targetHeight: targetH,
        );
        final resizedFrame = await resizedCodec.getNextFrame();
        final byteData = await resizedFrame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        resizedFrame.image.dispose();

        if (byteData != null) {
          final fallbackResult = byteData.buffer.asUint8List();
          if (fallbackResult.length < rawBytes.length) {
            return fallbackResult;
          }
        }
      } catch (_) {}
    }

    return rawBytes;
  }

  /// Comprueba rápidamente si las dimensiones de la imagen ya son menores o iguales a [maxDimension].
  static Future<bool> _isImageWithinDimension(
    File file,
    int maxDimension,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      frame.image.dispose();
      return width <= maxDimension && height <= maxDimension;
    } catch (_) {
      return true;
    }
  }

  /// Construye una ruta temporal limpia con extensión `.jpg` para el archivo optimizado.
  static String _buildCompressedTargetPath(String originalPath) {
    final tempDir = Directory.systemTemp.path;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final rawName = originalPath
        .split(Platform.pathSeparator)
        .last
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '$tempDir${Platform.pathSeparator}yago_opt_${timestamp}_$rawName.jpg';
  }
}
