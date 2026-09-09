import 'package:flutter/material.dart';
import '../../utils/design_system.dart';

enum YagoButtonVariant {
  primary,
  secondary,
  outline,
  destructive,
}

enum YagoButtonSize {
  large,
  defaultSize,
  small,
}

/// Botón oficial del Design System de Yago.
class YagoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final YagoButtonVariant variant;
  final YagoButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const YagoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = YagoButtonVariant.primary,
    this.size = YagoButtonSize.defaultSize,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensiones y tipografía según tamaño
    final (EdgeInsets padding, TextStyle textStyle, double height) = switch (size) {
      YagoButtonSize.large => (
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          AppTypography.headline.copyWith(fontSize: 17, color: _getTextColor()),
          52.0,
        ),
      YagoButtonSize.defaultSize => (
          const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          AppTypography.subheadlineMedium.copyWith(color: _getTextColor()),
          44.0,
        ),
      YagoButtonSize.small => (
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          AppTypography.footnoteMedium.copyWith(color: _getTextColor()),
          36.0,
        ),
    };

    final isEnabled = onPressed != null && !isLoading;

    final childContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          ),
          AppSpacing.gap8,
        ] else if (icon != null) ...[
          icon!,
          AppSpacing.gap8,
        ],
        Text(text, style: textStyle),
      ],
    );

    Widget buttonWidget;

    final buttonBorderRadius = BorderRadius.circular(28);

    switch (variant) {
      case YagoButtonVariant.primary:
        buttonWidget = Container(
          height: height,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.primary : AppColors.subtle,
            borderRadius: buttonBorderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: buttonBorderRadius,
              onTap: isEnabled ? onPressed : null,
              child: Padding(padding: padding, child: Center(child: childContent)),
            ),
          ),
        );
        break;

      case YagoButtonVariant.secondary:
        buttonWidget = Container(
          height: height,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.surfaceSecondary : AppColors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: buttonBorderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: buttonBorderRadius,
              onTap: isEnabled ? onPressed : null,
              child: Padding(padding: padding, child: Center(child: childContent)),
            ),
          ),
        );
        break;

      case YagoButtonVariant.outline:
        buttonWidget = Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: isEnabled ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            borderRadius: buttonBorderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: buttonBorderRadius,
              onTap: isEnabled ? onPressed : null,
              child: Padding(padding: padding, child: Center(child: childContent)),
            ),
          ),
        );
        break;

      case YagoButtonVariant.destructive:
        buttonWidget = Container(
          height: height,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.lost : AppColors.subtle,
            borderRadius: buttonBorderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: buttonBorderRadius,
              onTap: isEnabled ? onPressed : null,
              child: Padding(padding: padding, child: Center(child: childContent)),
            ),
          ),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }

  Color _getTextColor() {
    return switch (variant) {
      YagoButtonVariant.primary => Colors.white,
      YagoButtonVariant.secondary => AppColors.textPrimary,
      YagoButtonVariant.outline => AppColors.primary,
      YagoButtonVariant.destructive => Colors.white,
    };
  }
}

/// Botón de Icono cuadrado / redondeado oficial del Design System (44x44px).
class YagoIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final double size;
  final BorderRadius borderRadius;

  const YagoIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.surface,
    this.size = 44.0,
    this.borderRadius = AppRadius.mdBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          child: Center(child: icon),
        ),
      ),
    );
  }
}
