import 'package:flutter/material.dart';
import '../../widgets/common/widgets.dart';
import 'create_report_screen.dart';
import 'feed_tab.dart';
import 'pet_map_tab.dart';
import 'profile_tab.dart';
import 'search_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
    // Definición de las 4 vistas principales (el botón central 2 es la acción Publicar)
    final views = [
      FeedTab(
        onGoToSearch: () => setState(() => _currentIndex = 1),
        onGoToCreateReport: _openCreateReport,
      ),
      const SearchTab(),
      const SizedBox.shrink(), // Placeholder para el índice 2 (manejado por onPublishTap)
      const PetMapTab(),
      ProfileTab(
        onGoToCreateReport: _openCreateReport,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: YagoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onPublishTap: _openCreateReport,
      ),
    );
  }
}
