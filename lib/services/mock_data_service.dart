import '../models/event.dart';
import '../models/stand.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<Event> _events = [
    Event(
      id: 'evt-1',
      name: 'Feria Tecnológica e Innovación 2026',
      date: DateTime(2026, 9, 15),
      location: 'Centro de Convenciones Metropolitano - Salón A',
      description:
          'Encuentro anual de empresas tecnológicas, startups universitarias y proyectos de software e innovación.',
      stands: [
        const Stand(
          id: 'std-1',
          number: '01',
          status: StandStatus.occupied,
          exhibitorName: 'TechSolutions SRL',
          x: 40,
          y: 50,
        ),
        const Stand(
          id: 'std-2',
          number: '02',
          status: StandStatus.available,
          exhibitorName: null,
          x: 220,
          y: 50,
        ),
        const Stand(
          id: 'std-3',
          number: '03',
          status: StandStatus.occupied,
          exhibitorName: 'CloudDev Group',
          x: 130,
          y: 160,
        ),
        const Stand(
          id: 'std-4',
          number: '04',
          status: StandStatus.available,
          exhibitorName: null,
          x: 40,
          y: 270,
        ),
        const Stand(
          id: 'std-5',
          number: '05',
          status: StandStatus.occupied,
          exhibitorName: 'AI Labs Innovate',
          x: 220,
          y: 270,
        ),
      ],
    ),
    Event(
      id: 'evt-2',
      name: 'Expo Emprendedores Universitarios',
      date: DateTime(2026, 10, 4),
      location: 'Predio Ferial Universitario - Pabellón Central',
      description:
          'Muestra de proyectos productivos, diseño y tecnología desarrollada por estudiantes y graduados.',
      stands: [
        const Stand(
          id: 'std-201',
          number: '01',
          status: StandStatus.occupied,
          exhibitorName: 'EcoVaso Sustentable',
          x: 50,
          y: 60,
        ),
        const Stand(
          id: 'std-202',
          number: '02',
          status: StandStatus.available,
          x: 200,
          y: 60,
        ),
        const Stand(
          id: 'std-203',
          number: '03',
          status: StandStatus.available,
          x: 50,
          y: 180,
        ),
        const Stand(
          id: 'std-204',
          number: '04',
          status: StandStatus.occupied,
          exhibitorName: 'Robótica Educativa',
          x: 200,
          y: 180,
        ),
      ],
    ),
  ];

  List<Event> getEvents() => List.unmodifiable(_events);

  Event? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addEvent(Event event) {
    _events.insert(0, event);
  }

  void updateStand(String eventId, Stand updatedStand) {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _events[eventIndex];
      final standIndex = event.stands.indexWhere((s) => s.id == updatedStand.id);
      if (standIndex != -1) {
        final newStands = List<Stand>.from(event.stands);
        newStands[standIndex] = updatedStand;
        _events[eventIndex] = event.copyWith(stands: newStands);
      }
    }
  }
}
