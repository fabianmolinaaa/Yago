import 'package:flutter/material.dart';
import '../models/stand.dart';
import '../utils/app_colors.dart';

class StandMapView extends StatelessWidget {
  final List<Stand> stands;
  final ValueChanged<Stand>? onStandTap;
  final double mapWidth;
  final double mapHeight;

  const StandMapView({
    super.key,
    required this.stands,
    this.onStandTap,
    this.mapWidth = 360.0,
    this.mapHeight = 420.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Leyenda superior
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: AppColors.standAvailable,
                bgColor: AppColors.standAvailableBg,
                label: 'Disponible',
              ),
              const SizedBox(width: 20),
              _LegendItem(
                color: AppColors.standOccupied,
                bgColor: AppColors.standOccupiedBg,
                label: 'Ocupado',
              ),
            ],
          ),
        ),
        // Plano interactivo con zoom y desplazamiento
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.mapBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(80),
                minScale: 0.6,
                maxScale: 2.5,
                child: Center(
                  child: Container(
                    width: mapWidth,
                    height: mapHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        // Fondo con cuadrícula técnica
                        const Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),
                        // Stands posicionados según sus coordenadas (x, y)
                        ...stands.map((stand) {
                          return Positioned(
                            left: stand.x,
                            top: stand.y,
                            width: stand.width,
                            height: stand.height,
                            child: _StandBox(
                              stand: stand,
                              onTap: () => onStandTap?.call(stand),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StandBox extends StatelessWidget {
  final Stand stand;
  final VoidCallback onTap;

  const _StandBox({
    required this.stand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = stand.status == StandStatus.available;
    final primaryColor =
        isAvailable ? AppColors.standAvailable : AppColors.standOccupied;
    final bgColor =
        isAvailable ? AppColors.standAvailableBg : AppColors.standOccupiedBg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stand.number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAvailable ? 'Libre' : (stand.exhibitorName ?? 'Ocupado'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.bgColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine.withValues(alpha: 0.25)
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
