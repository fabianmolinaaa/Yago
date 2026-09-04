import 'package:flutter/material.dart';

/// Tokens de colores oficiales del Design System de Yago.
/// Fuente de verdad: Design System v1.0 (docs/DesignSystem.md)
class AppColors {
  AppColors._();

  // ─── Paleta de Marca Yago ──────────────────────────────────────────────────
  /// Naranja principal Yago (#FF6B35). Acciones primarias, CTA, acentos y FAB central.
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8555);
  static const Color primaryDark = Color(0xFFE5531E);
  static const Color primaryTint = Color(0xFFFFF2EC);

  /// Fondo de pantalla (#FFFFFF)
  static const Color background = Color(0xFFFFFFFF);

  /// Superficie elevada o fondos secundarios (#F5F5F7)
  static const Color surface = Color(0xFFF5F5F7);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Texto principal / Foreground (#1D1D1F)
  static const Color foreground = Color(0xFF1D1D1F);
  static const Color textPrimary = Color(0xFF1D1D1F);

  /// Texto secundario / Muted (#6E6E73)
  static const Color muted = Color(0xFF6E6E73);
  static const Color textSecondary = Color(0xFF6E6E73);

  /// Placeholders, bordes inactivos o terciarios (#AEAEB2)
  static const Color subtle = Color(0xFFAEAEB2);
  static const Color textMuted = Color(0xFFAEAEB2);

  /// Separadores y bordes hairline (#E5E5EA)
  static const Color border = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color feedDivider = Color(0xFFEFF3F4);

  /// Colores para feed estilo social (Twitter / LinkedIn)
  static const Color twitterHandle = Color(0xFF536471);
  static const Color twitterAction = Color(0xFF536471);
  static const Color retweetGreen = Color(0xFF00BA7C);
  static const Color likeRed = Color(0xFFF91880);
  static const Color viewBlue = Color(0xFF1D9BF0);

  /// Acento general (mismo que primary)
  static const Color accent = Color(0xFFFF6B35);

  // ─── Estados Semánticos (Publicaciones de Mascotas) ───────────────────────
  /// Mascota Perdida (#FF3B30)
  static const Color lost = Color(0xFFFF3B30);
  static const Color lostBg = Color(0xFFFFF2F1);

  /// Mascota Encontrada (#34C759)
  static const Color found = Color(0xFF34C759);
  static const Color foundBg = Color(0xFFF1FFF5);

  /// Mascota Reunida (#5AC8FA)
  static const Color reunited = Color(0xFF5AC8FA);
  static const Color reunitedBg = Color(0xFFF0FAFE);

  /// Publicación de Comunidad (#AF52DE)
  static const Color community = Color(0xFFAF52DE);
  static const Color communityBg = Color(0xFFF8F0FE);

  /// Nueva publicación / Alerta (#FF9500)
  static const Color statusNew = Color(0xFFFF9500);
  static const Color statusNewBg = Color(0xFFFFF8F0);

  // ─── Colores de mapa ──────────────────────────────────────────────────────
  static const Color mapBackground = Color(0xFFF5F5F7);
  static const Color gridLine = Color(0xFFE5E5EA);
}
