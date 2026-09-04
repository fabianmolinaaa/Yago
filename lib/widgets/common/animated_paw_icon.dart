import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Icono animado de patita de mascota:
/// - Almohadilla principal estática.
/// - Dedos apareciendo uno a uno en secuencia.
/// - Orientada apuntando hacia la esquina superior derecha.
/// - Monocromático (blanco por defecto).
class AnimatedPawIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedPawIcon({
    super.key,
    this.size = 20.0,
    this.color = Colors.white,
  });

  @override
  State<AnimatedPawIcon> createState() => _AnimatedPawIconState();
}

class _AnimatedPawIconState extends State<AnimatedPawIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PawPainter(
            animationValue: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _PawPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _PawPainter({
    required this.animationValue,
    required this.color,
  });

  double _calcToeProgress(double start, double end) {
    final t = animationValue;
    if (t < start) return 0.0;

    // Desvanecimiento suave al final del ciclo
    double fadeOut = 1.0;
    if (t >= 0.86 && t <= 0.96) {
      fadeOut = 1.0 - ((t - 0.86) / 0.10);
    } else if (t > 0.96) {
      fadeOut = 0.0;
    }

    if (t >= end) {
      return fadeOut;
    }

    final enterRatio = ((t - start) / (end - start)).clamp(0.0, 1.0);
    final popScale = Curves.easeOutBack.transform(enterRatio);
    return (popScale * fadeOut).clamp(0.0, 1.25);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 22.0;

    canvas.save();
    // Centrar en el canvas
    canvas.translate(size.width / 2, size.height / 2);
    // Rotar 45° para que los dedos apunten hacia la esquina superior derecha
    canvas.rotate(45 * math.pi / 180);
    canvas.scale(scale);

    // ─── 1. Almohadilla principal (ESTÁTICA) ──────────────────────
    final padPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final padPath = Path();
    padPath.moveTo(-5.5, 3.8);
    padPath.quadraticBezierTo(-2.5, 6.0, 0.0, 4.8);
    padPath.quadraticBezierTo(2.5, 6.0, 5.5, 3.8);
    padPath.quadraticBezierTo(6.6, 0.5, 3.5, -0.8);
    padPath.quadraticBezierTo(0.0, -1.8, -3.5, -0.8);
    padPath.quadraticBezierTo(-6.6, 0.5, -5.5, 3.8);
    padPath.close();

    canvas.drawPath(padPath, padPaint);

    // ─── 2. Dedos apareciendo uno a uno ─────────────────────────
    // Dedo 1 (exterior izquierdo): 0.00 -> 0.18
    final p1 = _calcToeProgress(0.00, 0.18);
    _drawToe(canvas, const Offset(-6.2, -1.5), 3.4, 4.6, -26 * math.pi / 180, p1);

    // Dedo 2 (interior izquierdo): 0.18 -> 0.36
    final p2 = _calcToeProgress(0.18, 0.36);
    _drawToe(canvas, const Offset(-2.3, -5.8), 3.5, 5.2, -10 * math.pi / 180, p2);

    // Dedo 3 (interior derecho): 0.36 -> 0.54
    final p3 = _calcToeProgress(0.36, 0.54);
    _drawToe(canvas, const Offset(2.3, -5.8), 3.5, 5.2, 10 * math.pi / 180, p3);

    // Dedo 4 (exterior derecho): 0.54 -> 0.72
    final p4 = _calcToeProgress(0.54, 0.72);
    _drawToe(canvas, const Offset(6.2, -1.5), 3.4, 4.6, 26 * math.pi / 180, p4);

    canvas.restore();
  }

  void _drawToe(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double tiltAngle,
    double progress,
  ) {
    if (progress <= 0.0) return;

    final alpha = (progress.clamp(0.0, 1.0) * (color.a)).clamp(0.0, 1.0);
    if (alpha <= 0.001) return;

    final toePaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);
    canvas.scale(progress);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      toePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PawPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
