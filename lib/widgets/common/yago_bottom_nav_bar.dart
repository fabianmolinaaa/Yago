import 'dart:ui';
import 'package:flutter/material.dart';

/// Barra de navegación inferior con estética frosted glass (vidrio esmerilado),
/// esquinas redondeadas, transparencia y desenfoque (blur) del fondo.
class YagoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onPublishTap;

  const YagoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onPublishTap,
  });

  // Colores monocromáticos minimalistas (sin colores llamativos)
  static const Color _activeColor = Color(0xFF0F1419); // Negro puro elegante
  static const Color _inactiveColor = Color(0xFF536471); // Gris neutro sutil

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                // Pequeña transparencia para dejar pasar la luz y colores del fondo
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 0: Inicio / Feed
                  _buildNavItem(
                    index: 0,
                    outlineIcon: Icons.home_outlined,
                    filledIcon: Icons.home_rounded,
                    tooltip: 'Inicio',
                  ),

                  // 1: Búsqueda / Explorar
                  _buildNavItem(
                    index: 1,
                    outlineIcon: Icons.search_rounded,
                    filledIcon: Icons.search_rounded,
                    tooltip: 'Buscar',
                  ),

                  // 2: Crear / Publicar (botón de acción limpio y minimalista)
                  _buildPublishItem(tooltip: 'Publicar mascota'),

                  // 3: Mapa / Ubicaciones
                  _buildNavItem(
                    index: 3,
                    outlineIcon: Icons.map_outlined,
                    filledIcon: Icons.map_rounded,
                    tooltip: 'Mapa',
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
          child: Center(child: Icon(icon, size: 26, color: color)),
        ),
      ),
    );
  }

  Widget _buildPublishItem({required String tooltip}) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onPublishTap ?? () => onTap(2),
          radius: 26,
          highlightShape: BoxShape.circle,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: _inactiveColor, width: 1.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: _activeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
