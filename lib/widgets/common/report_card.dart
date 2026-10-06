import 'package:flutter/material.dart';

import '../../models/pet.dart';
import '../../utils/design_system.dart';
import 'yago_badge.dart';
import 'yago_button.dart';
import 'yago_pet_image.dart';

/// Tarjeta visual estilo Pinterest (Masonry) diseñada para distribución
/// orgánica y limpia de fotografías de mascotas perdidas y encontradas.
///
/// La altura depende naturalmente de la propia imagen (aspect ratio intrínseco),
/// sin contenedores pesados ni bordes recargados, permitiendo una exploración
/// visual rápida para cotejar rasgos físicos de las mascotas.
class ReportGridCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onZoneTap;
  final VoidCallback? onOptionsTap;

  const ReportGridCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onZoneTap,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == YagoPetStatus.lost;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 1. Fotografía limpia estilo Pinterest con altura orgánica ────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: YagoPetImage(
                  imageUrl: pet.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholderHeight: 180,
                ),
              ),

              // Badge flotante sutil de estado (PERDIDA / ENCONTRADA)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (isLost ? AppColors.lost : AppColors.found)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    isLost ? 'PERDIDA' : 'ENCONTRADA',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ─── 2. Pie de foto minimalista estilo Pinterest (Nombre + ...) ───
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4, right: 2, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    pet.name.isNotEmpty ? pet.name : pet.breed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (onOptionsTap != null) {
                      onOptionsTap!();
                    } else if (onZoneTap != null) {
                      onZoneTap!();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta horizontal compacta para vista alternativa de lista
class ReportListCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onZoneTap;

  const ReportListCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == YagoPetStatus.lost;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLost
              ? AppColors.lost.withValues(alpha: 0.2)
              : AppColors.found.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    children: [
                      YagoPetImage(
                        imageUrl: pet.imageUrl,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isLost ? AppColors.lost : AppColors.found,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isLost ? 'PERDIDA' : 'HALLAZGO',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            pet.name.isNotEmpty ? pet.name : 'Sin nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          pet.timeAgo.isNotEmpty ? pet.timeAgo : 'Reciente',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.twitterHandle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pet.species} · ${pet.breed} · ${pet.gender}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            pet.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (onZoneTap != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: onZoneTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 13,
                                color: isLost
                                    ? AppColors.lost
                                    : AppColors.found,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Ver zona en mapa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isLost
                                      ? AppColors.lost
                                      : AppColors.found,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal inferior para visualización contextual de zona en mapa (HU-S2-02).
/// Cumple con la regla de Alcance.md: mapa contextual sin mapa libre global exploratorio.
class ContextualZoneModal extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onOpenFullDetail;

  const ContextualZoneModal({
    super.key,
    required this.pet,
    this.onOpenFullDetail,
  });

  static void show(BuildContext context, Pet pet, {VoidCallback? onOpenFullDetail}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ContextualZoneModal(
        pet: pet,
        onOpenFullDetail: onOpenFullDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == YagoPetStatus.lost;
    final accentColor = isLost ? AppColors.lost : AppColors.found;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle de arrastre
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Cabecera con datos de la mascota
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: YagoPetImage(
                    imageUrl: pet.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pet.name.isNotEmpty ? pet.name : 'Reporte de mascota',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          YagoStatusBadge(status: pet.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pet.breed} · ${pet.location}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mapa contextual simulado con radio aproximado
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECEF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _ContextualMapPainter(),
                  ),

                  // Círculo de radio contextual de búsqueda / avistamiento
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Pin central con icono
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  // Etiqueta flotante con el barrio/zona
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            size: 15,
                            color: accentColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Radio estimado de 500m alrededor de ${pet.location}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nota informativa de privacidad
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: AppColors.muted,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Por seguridad comunitaria, se muestra un radio contextual aproximado del hecho.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón de acción principal
            SizedBox(
              width: double.infinity,
              child: YagoButton(
                text: 'Ver ficha completa de ${pet.name.isNotEmpty ? pet.name : "la mascota"}',
                onPressed: () {
                  Navigator.pop(context);
                  onOpenFullDetail?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextualMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = const Color(0xFFDFE4E8)
      ..style = PaintingStyle.fill;

    // Manzanas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 16, size.width * 0.4, 70),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, 16, size.width * 0.45, 70),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 105, size.width * 0.4, 75),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, 105, size.width * 0.45, 75),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Calles
    canvas.drawLine(
      Offset(0, size.height * 0.48),
      Offset(size.width, size.height * 0.48),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, 0),
      Offset(size.width * 0.46, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
