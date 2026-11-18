import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/common/widgets.dart';
import 'ai_camera_screen.dart';
import 'create_report_screen.dart';
import 'direct_chats_tab.dart';
import 'feed_tab.dart';
import 'profile_tab.dart';
import 'reports_feed_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isNavCompact = false;

  void _openCreateReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          onReportCreated: () {
            setState(() {
              _currentIndex = 0; // Volver al feed
            });
          },
        ),
      ),
    );
  }

  void _closeCameraScanner() {
    setState(() {
      _currentIndex = _previousIndex == 2 ? 0 : _previousIndex;
      _isNavCompact = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCameraOpen = _currentIndex == 2;

    // Definición de las 5 vistas principales del alcance oficial:
    // 0: Feed de publicaciones (activo)
    // 1: Feed de reportes (activo con visor de zona en mapa)
    // 2: Cámara para análisis con IA (escáner directo a pantalla completa)
    // 3: Chat directo entre personas (Próximamente)
    // 4: Perfil de usuario (activo)
    final views = [
      FeedTab(
        onGoToSearch: () => setState(() => _currentIndex = 1),
        onGoToCreateReport: _openCreateReport,
      ),
      ReportsFeedTab(
        onGoToCreateReport: _openCreateReport,
      ),
      AiCameraScreen(
        isActive: isCameraOpen,
        onClose: _closeCameraScanner,
        onReportCreated: () {
          setState(() {
            _currentIndex = 1; // Ir al feed de reportes tras publicar hallazgo
          });
        },
      ),
      DirectChatsTab(
        onGoToFeed: () => setState(() => _currentIndex = 0),
        onGoToReports: () => setState(() => _currentIndex = 1),
      ),
      ProfileTab(
        onGoToCreateReport: _openCreateReport,
      ),
    ];

    return ListenableBuilder(
      listenable: MockDataService(),
      builder: (context, _) {
        final unreadChats = MockDataService().getTotalUnreadChatCount();

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
          bottomNavigationBar: isCameraOpen
              ? null
              : YagoBottomNavBar(
                  currentIndex: _currentIndex,
                  isCompact: _isNavCompact,
                  unreadChatsCount: unreadChats,
                  onTap: (index) {
                    setState(() {
                      if (index != 2) {
                        _previousIndex = index;
                      } else if (_currentIndex != 2) {
                        _previousIndex = _currentIndex;
                      }
                      _currentIndex = index;
                      _isNavCompact = false;
                    });
                  },
                  onPublishTap: _openCreateReport,
                ),
        );
      },
    );
  }
}
