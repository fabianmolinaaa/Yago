import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../utils/design_system.dart';

export '../../models/pet.dart' show YagoPetStatus;

/// Extensión de presentación para mapear estados de dominio a estilos visuales del Design System.
extension YagoPetStatusUI on YagoPetStatus {
  String get label {
    switch (this) {
      case YagoPetStatus.lost:
        return 'PERDIDA';
      case YagoPetStatus.found:
        return 'ENCONTRADA';
      case YagoPetStatus.reunited:
        return 'REUNIDA';
      case YagoPetStatus.community:
        return 'COMUNIDAD';
      case YagoPetStatus.urgent:
        return 'URGENTE';
      case YagoPetStatus.isNew:
        return 'NUEVA';
    }
  }

  Color get color {
    switch (this) {
      case YagoPetStatus.lost:
      case YagoPetStatus.urgent:
        return AppColors.lost;
      case YagoPetStatus.found:
        return AppColors.found;
      case YagoPetStatus.reunited:
        return AppColors.reunited;
      case YagoPetStatus.community:
        return AppColors.community;
      case YagoPetStatus.isNew:
        return AppColors.statusNew;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case YagoPetStatus.lost:
      case YagoPetStatus.urgent:
        return AppColors.lostBg;
      case YagoPetStatus.found:
        return AppColors.foundBg;
      case YagoPetStatus.reunited:
        return AppColors.reunitedBg;
      case YagoPetStatus.community:
        return AppColors.communityBg;
      case YagoPetStatus.isNew:
        return AppColors.statusNewBg;
    }
  }
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
