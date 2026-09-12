import 'package:flutter/material.dart';
import '../../utils/design_system.dart';
import 'yago_logo.dart';

/// Vista reutilizable para pantallas en construcción o planificadas ("Próximamente").
/// Sigue rigurosamente el Design System minimalista de Yago (estilo nórdico, paleta slate/neutra).
class ComingSoonView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final Color? accentColor;
  final String? featureHighlight;

  const ComingSoonView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.badgeText = 'EN CONSTRUCCIÓN',
    this.accentColor,
    this.featureHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.feedDivider, width: 1),
        ),
        title: Row(
          children: [
            const YagoLogoIcon(size: 26),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono dentro de contenedor suave redondeado
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: effectiveColor.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 42,
                      color: effectiveColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Badge de estado ("EN CONSTRUCCIÓN" o "PRÓXIMAMENTE")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: effectiveColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: effectiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Título principal
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Descripción del alcance y valor de la funcionalidad
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Tarjeta con detalle o valor destacado
                if (featureHighlight != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            featureHighlight!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Texto sutil de pie
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.engineering_outlined,
                      size: 16,
                      color: AppColors.subtle,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Módulo en desarrollo para el próximo sprint',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Margen para que no tape el dock flotante
              ],
            ),
          ),
        ),
      ),
    );
  }
}
