import 'package:flutter/material.dart';
import '../../utils/design_system.dart';
import 'yago_badge.dart';

/// Card de publicación de mascota basada en las directrices del Design System de Yago.
class PetCard extends StatelessWidget {
  final String name;
  final String details; // ej: "Lhasa Apso · Hembra · 3 años"
  final String locationAndTime; // ej: "Palermo, CABA · hace 6 horas · 800m"
  final String imageUrl;
  final YagoPetStatus status;
  final List<String> tags;
  final String? storyText; // Opcional para mascotas reunidas
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const PetCard({
    super.key,
    required this.name,
    required this.details,
    required this.locationAndTime,
    required this.imageUrl,
    required this.status,
    this.tags = const [],
    this.storyText,
    this.onTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen superior con badges superpuestos
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(Icons.pets, size: 48, color: AppColors.subtle),
                      ),
                    ),
                  ),
                ),
                // Badge de estado flotante (arriba a la izquierda)
                Positioned(
                  top: 12,
                  left: 12,
                  child: YagoStatusBadge(status: status),
                ),
                // Botón de bookmark (arriba a la derecha)
                if (onBookmarkTap != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: onBookmarkTap,
                      borderRadius: AppRadius.fullBorder,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 16,
                          color: isBookmarked ? AppColors.primary : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y detalles
                  Text(
                    name,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: AppTypography.footnote.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),

                  // Ubicación y tiempo
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.subtle),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationAndTime,
                          style: AppTypography.caption.copyWith(color: AppColors.subtle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (storyText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      storyText!,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Tags de características y botón 'Ver más'
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (tags.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: tags
                                .take(3)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: AppRadius.fullBorder,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      else
                        const Spacer(),
                      Text(
                        'Ver más →',
                        style: AppTypography.footnoteMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
