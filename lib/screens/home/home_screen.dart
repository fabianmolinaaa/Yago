import 'package:flutter/material.dart';
import 'my_events_tab.dart';
import 'create_event_tab.dart';
import 'profile_tab.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Mis Eventos',
    'Crear Evento',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      MyEventsTab(
        onGoToCreateEvent: () => setState(() => _currentIndex = 1),
      ),
      CreateEventTab(
        onEventCreated: () => setState(() => _currentIndex = 0),
      ),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              tooltip: 'Crear evento',
              onPressed: () => setState(() => _currentIndex = 1),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Mis eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Crear evento',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
