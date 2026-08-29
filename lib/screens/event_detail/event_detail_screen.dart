import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_colors.dart';
import 'stand_map_tab.dart';
import 'stand_list_tab.dart';
import 'event_info_tab.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event? _event;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  void _loadEvent() {
    setState(() {
      _event = MockDataService().getEventById(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Evento')),
        body: const Center(child: Text('No se encontró el evento solicitado')),
      );
    }

    final event = _event!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            event.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Icon(Icons.map_outlined, size: 20),
                text: 'Mapa de stands',
              ),
              Tab(
                icon: Icon(Icons.view_list_rounded, size: 20),
                text: 'Stands',
              ),
              Tab(
                icon: Icon(Icons.info_outline_rounded, size: 20),
                text: 'Información',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StandMapTab(
              event: event,
              onStandUpdated: _loadEvent,
            ),
            StandListTab(event: event),
            EventInfoTab(event: event),
          ],
        ),
      ),
    );
  }
}
