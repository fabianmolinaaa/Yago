import 'package:flutter/material.dart';

/// Tokens de colores oficiales del Design System de Yago (v2.0 Minimalist Slate).
/// Fuente de verdad: Design System v2.0 (docs/DesignSystem.md)
class AppColors {
  AppColors._();

  // ─── Paleta de Marca Yago (Nordic Minimalist Slate v2.5) ───────────────────
  /// Color primario Grafito Slate Profundo (#232E3A). Acciones principales, botones CTA pill y chips destacados.
  static const Color primary = Color(0xFF232E3A);
  /// Slate medio (#3B4856) para estados hover, pressed o elementos secundarios destacados.
  static const Color primaryLight = Color(0xFF3B4856);
  /// Grafito noche (#18202A) para máxima jerarquía, logos y cabeceras.
  static const Color primaryDark = Color(0xFF18202A);
  /// Tinte Slate (#F1F4F8) para fondos de iconos de acción y contenedores suaves.
  static const Color primaryTint = Color(0xFFF1F4F8);

  /// Fondo de pantalla general (#FFFFFF) — Lienzo blanco puro y luminoso como en Onboarding.
  static const Color background = Color(0xFFFFFFFF);

  /// Superficie elevada o fondos de tarjetas / inputs / dock (#FFFFFF).
  static const Color surface = Color(0xFFFFFFFF);
  /// Superficie secundaria (#F7F8FA) para contenedores de iconos y chips inactivos.
  static const Color surfaceSecondary = Color(0xFFF7F8FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Texto principal / Foreground (#1D232C) — Grafito pizarra profundo, suave para la vista.
  static const Color foreground = Color(0xFF1D232C);
  static const Color textPrimary = Color(0xFF1D232C);

  /// Texto secundario / Muted (#737C8A) — Subtítulos, metadatos y descripciones editoriales.
  static const Color muted = Color(0xFF737C8A);
  static const Color textSecondary = Color(0xFF737C8A);

  /// Placeholders, iconos inactivos y bordes tenues (#9AA1AC).
  static const Color subtle = Color(0xFF9AA1AC);
  static const Color textMuted = Color(0xFF9AA1AC);

  /// Separadores y bordes hairline (#E8ECF2).
  static const Color border = Color(0xFFE8ECF2);
  static const Color borderSubtle = Color(0xFFF0F3F7);
  static const Color divider = Color(0xFFE8ECF2);
  static const Color feedDivider = Color(0xFFF0F3F7);

  /// Colores para feed e interacciones sociales
  static const Color twitterHandle = Color(0xFF737C8A);
  static const Color twitterAction = Color(0xFF737C8A);
  static const Color retweetGreen = Color(0xFF4FA175);
  static const Color likeRed = Color(0xFFD46761);
  static const Color viewBlue = Color(0xFF4D88C5);

  /// Acento general
  static const Color accent = Color(0xFF5E6672);

  // ─── Estados Semánticos (Minimalist Slate & Reencuentro Exitoso) ───────────
  /// Error o alerta crítica del sistema (#D46761)
  static const Color error = Color(0xFFD46761);
  static const Color errorBg = Color(0xFFFCECEB);
  static const Color errorText = Color(0xFFC45953);

  /// Mascota Perdida (Búsqueda activa: Slate oscuro neutro #232E3A)
  static const Color lost = Color(0xFF232E3A);
  static const Color lostBg = Color(0xFFF1F4F8);
  static const Color lostText = Color(0xFF232E3A);

  /// Mascota Encontrada (Búsqueda activa / En custodia: Slate medio neutro #4B5563)
  static const Color found = Color(0xFF4B5563);
  static const Color foundBg = Color(0xFFF3F4F6);
  static const Color foundText = Color(0xFF374151);

  /// Mascota Reunida (Éxito / Caso resuelto / Regresó con su familia: Sage Green #4FA175)
  static const Color reunited = Color(0xFF4FA175);
  static const Color reunitedBg = Color(0xFFEAF5EE);
  static const Color reunitedText = Color(0xFF428C63);

  /// Publicación de Comunidad (Muted Slate / Indigo #6E7B8E)
  static const Color community = Color(0xFF6E7B8E);
  static const Color communityBg = Color(0xFFF2ECF7);
  static const Color communityText = Color(0xFF70628E);

  /// Búsqueda de Pareja / Apareamiento (Violeta Nórdico Suave #7C5CBF)
  static const Color mating = Color(0xFF7C5CBF);
  static const Color matingBg = Color(0xFFF3EBF9);
  static const Color matingText = Color(0xFF6B48B0);

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
