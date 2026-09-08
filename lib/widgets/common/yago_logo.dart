import 'package:flutter/material.dart';

/// Widget oficial para renderizar el isotipo o imagotipo de Yago.
class YagoLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const YagoLogo({
    super.key,
    this.width,
    this.height = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/yago_logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              'Yago',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        );
      },
    );
  }
}

/// Isotipo (solo el icono del perro y gato) para uso en headers, avatares y elementos compactos.
class YagoLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const YagoLogoIcon({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/yago_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.pets_rounded,
          size: size * 0.8,
          color: color,
        );
      },
    );
  }
}
