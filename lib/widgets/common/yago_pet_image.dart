import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Widget optimizado para renderizar imágenes de mascotas en Yago.
/// Resuelve automáticamente assets locales empaquetados para carga instantánea
/// y sin consumo de red, y proporciona un cargador con fallback ante URLs remotas.
class YagoPetImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? placeholderHeight;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const YagoPetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholderHeight,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  /// Mapea URLs remotas conocidas de Firebase Storage a sus assets locales compilados en la app
  static String? resolveAssetFallback(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('assets/')) return trimmed;
    final lower = trimmed.toLowerCase();
    if (lower.contains('luna_caniche') || lower.contains('img_3508')) {
      return 'assets/images/IMG_3508.JPG';
    }
    if (lower.contains('rocky_labrador') || lower.contains('img_4178')) {
      return 'assets/images/IMG_4178.JPG';
    }
    if (lower.contains('simba_golden') || lower.contains('img_5370')) {
      return 'assets/images/IMG_5370.JPG';
    }
    if (lower.contains('milo_gato') || lower.contains('img_2935')) {
      return 'assets/images/IMG_2935.JPG';
    }
    if (lower.contains('luna_reunida') || lower.contains('img_5667')) {
      return 'assets/images/IMG_5667.JPG';
    }
    if (lower.contains('thor_boyero')) {
      return 'assets/images/IMG_5370.JPG';
    }
    if (lower.contains('luna_final_feliz') || lower.contains('img_5560')) {
      return 'assets/images/IMG_5560.JPG';
    }
    return null;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height ?? placeholderHeight ?? 220,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.pets_rounded,
        size: 48,
        color: AppColors.subtle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetFallback = resolveAssetFallback(imageUrl);

    Widget imageWidget;

    // Si coincide con un asset local empaquetado, cargarlo inmediatamente (0 ms, offline)
    if (assetFallback != null) {
      imageWidget = Image.asset(
        assetFallback,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Imagen remota dinámica (ej. fotos subidas por usuarios a Cloud Storage)
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height ?? placeholderHeight ?? 220,
            color: AppColors.surface,
            alignment: Alignment.center,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
