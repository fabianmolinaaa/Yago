import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Configuración de ThemeData oficial de Yago.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.surfaceSecondary,
        onSecondary: AppColors.textPrimary,
        error: AppColors.lost,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar minimalista estilo iOS
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),

      // Cards limpias con borde sutil
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Campos de texto según Design System
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.subheadline.copyWith(color: AppColors.subtle),
        labelStyle: AppTypography.footnoteMedium,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.lost, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.lost, width: 2),
        ),
      ),

      // Botones primarios elevados / CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),

      // Botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Barra de navegación inferior
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
            color: AppColors.subtle,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark);
          }
          return const IconThemeData(color: AppColors.subtle);
        }),
      ),

      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
