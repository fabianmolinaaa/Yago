import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pet.dart';
import '../../utils/design_system.dart';
import 'yago_badge.dart';
import 'yago_button.dart';
import 'yago_pet_image.dart';

/// Tarjeta visual estilo Pinterest (Masonry) diseñada para distribución
/// orgánica y limpia de fotografías de mascotas perdidas y encontradas.
///
/// La fotografía es 100% limpia sin chips ni badges de colores invasivos superpuestos.
/// La altura se adapta naturalmente al aspect ratio de la imagen.
/// El estado (Perdida / Encontrada) se comunica de forma moderna y sutil en el pie de foto
/// mediante un micro-indicador y tipografía limpia junto al barrio.
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
    final neighborhood = pet.location.isNotEmpty
        ? pet.location.split(',')[0].trim()
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 1. Fotografía 100% limpia estilo Pinterest (sin chips invasivos) ──
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: YagoPetImage(
              imageUrl: pet.imageUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              placeholderHeight: 180,
            ),
          ),

          // ─── 2. Pie de foto minimalista con micro-indicador tipográfico ───
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 2, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre de la mascota
                      Text(
                        pet.name.isNotEmpty ? pet.name : pet.breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Estado sutil con micro-punto indicador y barrio
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.subtle,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            isLost ? 'Perdida' : 'Encontrada',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (neighborhood.isNotEmpty) ...[
                            Expanded(
                              child: Text(
                                ' · $neighborhood',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón minimalista de opciones (...)
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
                      size: 19,
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
    final neighborhood = pet.location.isNotEmpty
        ? pet.location.split(',')[0].trim()
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
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
                  child: YagoPetImage(
                    imageUrl: pet.imageUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
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
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.subtle,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4.5),
                        Text(
                          isLost ? 'Perdida' : 'Encontrada',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (neighborhood.isNotEmpty) ...[
                          Text(
                            ' · $neighborhood',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species} · ${pet.breed}',
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
                    if (onZoneTap != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: onZoneTap,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Ver zona en mapa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
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

  Future<void> _openInMaps(BuildContext context) async {
    final lat = pet.latitude;
    final lng = pet.longitude;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la aplicación de mapas.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la aplicación de mapas.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

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

            // Cabecera con datos de la mascota (tocar abre ficha completa)
            InkWell(
              onTap: () {
                Navigator.pop(context);
                onOpenFullDetail?.call();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
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
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
              ),
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

            // Botón de acción principal: Abrir en Maps
            SizedBox(
              width: double.infinity,
              child: YagoButton(
                text: 'Abrir en Maps',
                icon: const Icon(
                  Icons.map_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () => _openInMaps(context),
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
