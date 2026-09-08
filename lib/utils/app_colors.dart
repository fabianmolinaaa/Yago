import 'package:flutter/material.dart';

/// Tokens de colores oficiales del Design System de Yago (v2.0 Minimalist Slate).
/// Fuente de verdad: Design System v2.0 (docs/DesignSystem.md)
class AppColors {
  AppColors._();

  // ─── Paleta de Marca Yago (Nordic Minimalist Slate) ────────────────────────
  /// Color primario Slate Blue-Grey (#5E6672). Acciones principales, botones CTA y chips activos.
  static const Color primary = Color(0xFF5E6672);
  /// Slate medio (#78818F) para estados hover, pressed o botones secundarios destacados.
  static const Color primaryLight = Color(0xFF78818F);
  /// Grafito profundo / Slate Dark (#2B323D) para identidad, logos y encabezados.
  static const Color primaryDark = Color(0xFF2B323D);
  /// Tinte Slate (#EFF2F6) para fondos de iconos de acción y chips neutros suaves.
  static const Color primaryTint = Color(0xFFEFF2F6);

  /// Fondo de pantalla general (#F7F8FA) — Lienzo limpio tipo porcelana/soft-grey.
  static const Color background = Color(0xFFF7F8FA);

  /// Superficie elevada o fondos de tarjetas / inputs / dock (#FFFFFF).
  static const Color surface = Color(0xFFFFFFFF);
  /// Superficie secundaria (#F1F3F6) para contenedores de iconos y chips inactivos.
  static const Color surfaceSecondary = Color(0xFFF1F3F6);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Texto principal / Foreground (#1D232C) — Grafito pizarra profundo, suave para la vista.
  static const Color foreground = Color(0xFF1D232C);
  static const Color textPrimary = Color(0xFF1D232C);

  /// Texto secundario / Muted (#737C8A) — Subtítulos, metadatos y descripciones.
  static const Color muted = Color(0xFF737C8A);
  static const Color textSecondary = Color(0xFF737C8A);

  /// Placeholders, iconos inactivos y bordes tenues (#9AA1AC).
  static const Color subtle = Color(0xFF9AA1AC);
  static const Color textMuted = Color(0xFF9AA1AC);

  /// Separadores y bordes hairline (#E3E6EC).
  static const Color border = Color(0xFFE3E6EC);
  static const Color borderSubtle = Color(0xFFECEFF3);
  static const Color divider = Color(0xFFE3E6EC);
  static const Color feedDivider = Color(0xFFECEFF3);

  /// Colores para feed e interacciones sociales
  static const Color twitterHandle = Color(0xFF737C8A);
  static const Color twitterAction = Color(0xFF737C8A);
  static const Color retweetGreen = Color(0xFF4FA175);
  static const Color likeRed = Color(0xFFD46761);
  static const Color viewBlue = Color(0xFF4D88C5);

  /// Acento general
  static const Color accent = Color(0xFF5E6672);

  // ─── Estados Semánticos (Pasteles Terrosos Desaturados) ─────────────────────
  /// Mascota Perdida (Dusty Coral / Terracota #D46761)
  static const Color lost = Color(0xFFD46761);
  static const Color lostBg = Color(0xFFFCECEB);
  static const Color lostText = Color(0xFFC45953);

  /// Mascota Encontrada (Sage Green / Eucalipto #4FA175)
  static const Color found = Color(0xFF4FA175);
  static const Color foundBg = Color(0xFFEAF5EE);
  static const Color foundText = Color(0xFF428C63);

  /// Mascota Reunida (Slate Sky Blue / Celeste Pizarra #4D88C5)
  static const Color reunited = Color(0xFF4D88C5);
  static const Color reunitedBg = Color(0xFFEBF3FB);
  static const Color reunitedText = Color(0xFF3D76B1);

  /// Publicación de Comunidad (Muted Slate / Indigo #6E7B8E)
  static const Color community = Color(0xFF6E7B8E);
  static const Color communityBg = Color(0xFFF2ECF7);
  static const Color communityText = Color(0xFF70628E);

  /// Nueva publicación / Alerta
  static const Color statusNew = Color(0xFFD46761);
  static const Color statusNewBg = Color(0xFFFCECEB);

  // ─── Badges de fotos y marca de agua ───────────────────────────────────────
  static const Color distanceBadgeBg = Color(0xFFFFFFFF);
  static const Color distanceBadgeText = Color(0xFF454E5B);
  static const Color watermark = Color(0xFFE8ECEE);

  // ─── Colores de mapa ───────────────────────────────────────────────────────
  static const Color mapBackground = Color(0xFFF7F8FA);
  static const Color gridLine = Color(0xFFE3E6EC);
}
