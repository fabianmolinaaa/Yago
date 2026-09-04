import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Jerarquía tipográfica oficial del Design System de Yago.
/// Basada en Inter / iOS Human Interface Guidelines.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  /// Display: 34px, FontWeight.w200, tracking -0.02em
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w200,
    letterSpacing: -0.68,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  /// Title 1: 28px, FontWeight.w300, tracking -0.015em
  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.42,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Title 2: 22px, FontWeight.w400, tracking -0.01em
  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.22,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  /// Title 2 Bold (o Semibold para títulos de sección destacados)
  static const TextStyle title2Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  /// Headline: 17px, FontWeight.w600, tracking -0.005em
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Body: 17px, FontWeight.w400, tracking 0
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Callout: 16px, FontWeight.w400, tracking 0
  static const TextStyle callout = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Subheadline: 15px, FontWeight.w400, tracking 0.005em
  static const TextStyle subheadline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Subheadline Medium (para labels de botones secundarios o destacados)
  static const TextStyle subheadlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.07,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Footnote: 13px, FontWeight.w400, tracking 0.005em
  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  /// Footnote Medium (para labels de formulario o autor)
  static const TextStyle footnoteMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.06,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  /// Caption: 12px, FontWeight.w400, tracking 0.01em
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
    color: AppColors.textMuted,
    height: 1.3,
  );

  /// Caption Bold / Medium (para badges o estados de publicación)
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.44,
    height: 1.2,
  );

  /// Section Label (01 — Foundation, etc.)
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
    color: AppColors.primary,
  );
}
