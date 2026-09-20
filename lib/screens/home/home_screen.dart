import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../utils/design_system.dart';
import '../../widgets/common/widgets.dart';
import 'create_report_screen.dart';
import 'feed_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isNavCompact = false;

  void _openCreateReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          onReportCreated: () {
            Navigator.of(context).pop();
            setState(() {
              _currentIndex = 0; // Volver al feed
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definición de las 5 vistas principales del nuevo alcance:
    // 0: Feed de publicaciones (activo)
    // 1: Feed de reportes (Próximamente con visor de zona en mapa)
    // 2: Cámara para análisis con IA (Próximamente con escaneo y búsqueda en BD)
    // 3: Chat directo entre personas (Próximamente)
    // 4: Perfil de usuario (activo)
    final views = [
      FeedTab(
        onGoToSearch: () => setState(() => _currentIndex = 1),
        onGoToCreateReport: _openCreateReport,
      ),
      const ComingSoonView(
        title: 'Feed de Reportes',
        description:
            'Espacio dedicado exclusivamente a reportes de mascotas perdidas y encontradas, con alertas prioritarias y visualización de zona en mapa.',
        icon: Icons.campaign_outlined,
        badgeText: 'PRÓXIMAMENTE',
        accentColor: AppColors.lost,
        featureHighlight:
            'Cada reporte incluirá una opción directa para ver en qué zona del mapa se pudo haber perdido o visto por última vez a la mascota.',
      ),
      const ComingSoonView(
        title: 'Cámara con IA',
        description:
            '¿Encontraste un animal en la calle? Toma una foto y nuestra IA analizará sus rasgos físicos para buscarlo dentro de la base de datos de mascotas perdidas.',
        icon: Icons.center_focus_strong_rounded,
        badgeText: 'PRÓXIMAMENTE',
        accentColor: AppColors.primary,
        featureHighlight:
            'Identificación inteligente al instante en la vía pública con aviso y contacto directo al dueño.',
      ),
      const ComingSoonView(
        title: 'Chat Directo',
        description:
            'Canal de mensajería instantánea 1 a 1 para aportar pistas de avistamientos o coordinar el reencuentro de las mascotas de forma privada y segura.',
        icon: Icons.chat_bubble_outline_rounded,
        badgeText: 'PRÓXIMAMENTE',
        accentColor: AppColors.found,
        featureHighlight:
            'Bandeja de conversaciones vinculadas directamente al reporte de la mascota para actuar con rapidez.',
      ),
      ProfileTab(
        onGoToCreateReport: _openCreateReport,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (!_isNavCompact) {
              setState(() => _isNavCompact = true);
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (_isNavCompact) {
              setState(() => _isNavCompact = false);
            }
          }
          return false;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: views,
        ),
      ),
      bottomNavigationBar: YagoBottomNavBar(
        currentIndex: _currentIndex,
        isCompact: _isNavCompact,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _isNavCompact = false;
          });
        },
        onPublishTap: _openCreateReport,
      ),
    );
  }
}
