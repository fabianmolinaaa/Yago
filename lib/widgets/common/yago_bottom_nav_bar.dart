import 'dart:ui';
import 'package:flutter/material.dart';

/// Barra de navegación inferior con estética frosted glass (vidrio esmerilado),
/// esquinas redondeadas, transparencia y desenfoque (blur) del fondo.
class YagoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onPublishTap;
  final bool isCompact;

  const YagoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onPublishTap,
    this.isCompact = false,
  });

  // Colores monocromáticos minimalistas (sin colores llamativos)
  static const Color _activeColor = Color(0xFF0F1419); // Negro puro elegante
  static const Color _inactiveColor = Color(0xFF536471); // Gris neutro sutil

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.fromLTRB(
          isCompact ? 32.0 : 16.0,
          0,
          isCompact ? 32.0 : 16.0,
          isCompact ? 6.0 : 10.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              height: isCompact ? 44.0 : 54.0,
              decoration: BoxDecoration(
                // Pequeña transparencia para dejar pasar la luz y colores del fondo
                color: Colors.white.withValues(alpha: isCompact ? 0.90 : 0.82),
                borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isCompact ? 0.04 : 0.06),
                    blurRadius: isCompact ? 12 : 16,
                    offset: Offset(0, isCompact ? 2 : 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 0: Feed de publicaciones comunitarias
                  _buildNavItem(
                    index: 0,
                    outlineIcon: Icons.home_outlined,
                    filledIcon: Icons.home_rounded,
                    tooltip: 'Publicaciones',
                  ),

                  // 1: Feed de reportes de pérdidas y hallazgos
                  _buildNavItem(
                    index: 1,
                    outlineIcon: Icons.campaign_outlined,
                    filledIcon: Icons.campaign_rounded,
                    tooltip: 'Reportes',
                  ),

                  // 2: Cámara para análisis con IA (botón central con obturador/escáner)
                  _buildCameraItem(tooltip: 'Cámara con IA'),

                  // 3: Chat directo entre personas
                  _buildNavItem(
                    index: 3,
                    outlineIcon: Icons.chat_bubble_outline_rounded,
                    filledIcon: Icons.chat_bubble_rounded,
                    tooltip: 'Chat',
                  ),

                  // 4: Perfil / Cuenta
                  _buildNavItem(
                    index: 4,
                    outlineIcon: Icons.person_outline_rounded,
                    filledIcon: Icons.person_rounded,
                    tooltip: 'Perfil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData outlineIcon,
    required IconData filledIcon,
    required String tooltip,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? _activeColor : _inactiveColor;
    final icon = isSelected ? filledIcon : outlineIcon;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: () => onTap(index),
          radius: 26,
          highlightShape: BoxShape.circle,
          child: Center(
            child: AnimatedScale(
              scale: isCompact ? 0.85 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: Icon(icon, size: 26, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraItem({required String tooltip}) {
    final isSelected = currentIndex == 2;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: () => onTap(2),
          radius: 26,
          highlightShape: BoxShape.circle,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              width: isCompact ? 28 : 34,
              height: isCompact ? 28 : 34,
              decoration: BoxDecoration(
                color: isSelected ? _activeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _activeColor : _inactiveColor,
                  width: isCompact ? 1.3 : 1.6,
                ),
                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
              ),
              child: Icon(
                Icons.center_focus_strong_rounded,
                size: isCompact ? 16 : 20,
                color: isSelected ? Colors.white : _activeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
