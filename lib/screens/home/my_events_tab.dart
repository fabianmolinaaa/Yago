import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/event_card.dart';
import '../../utils/app_colors.dart';
import '../event_detail/event_detail_screen.dart';

class MyEventsTab extends StatelessWidget {
  final VoidCallback? onGoToCreateEvent;

  const MyEventsTab({
    super.key,
    this.onGoToCreateEvent,
  });

  @override
  Widget build(BuildContext context) {
    final events = MockDataService().getEvents();

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy_rounded,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                'No tienes eventos creados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu primer evento para comenzar a organizar y distribuir los stands.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onGoToCreateEvent,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear evento'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(eventId: event.id),
              ),
            );
          },
        );
      },
    );
  }
}
