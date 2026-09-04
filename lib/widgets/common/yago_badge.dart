import 'package:flutter/material.dart';
import '../../utils/design_system.dart';

enum YagoPetStatus {
  lost('PERDIDA', AppColors.lost, AppColors.lostBg),
  found('ENCONTRADA', AppColors.found, AppColors.foundBg),
  reunited('REUNIDA', AppColors.reunited, AppColors.reunitedBg),
  community('COMUNIDAD', AppColors.community, AppColors.communityBg),
  urgent('URGENTE', AppColors.lost, AppColors.lostBg),
  isNew('NUEVA', AppColors.statusNew, AppColors.statusNewBg);

  final String label;
  final Color color;
  final Color backgroundColor;

  const YagoPetStatus(this.label, this.color, this.backgroundColor);
}

/// Badge oficial para estados de publicación de mascotas.
class YagoStatusBadge extends StatelessWidget {
  final YagoPetStatus status;
  final String? customLabel;
  final bool isUppercase;

  const YagoStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.isUppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final text = customLabel ?? status.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        isUppercase ? text.toUpperCase() : text,
        style: AppTypography.captionBold.copyWith(
          color: status.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Tag / Chip oficial para características de la mascota (ej: "Collar rojo", "Hembra", etc.).
class YagoFeatureTag extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const YagoFeatureTag({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.footnote.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
