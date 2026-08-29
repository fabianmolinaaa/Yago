import 'stand.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final List<Stand> stands;

  const Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    this.stands = const [],
  });

  int get totalStands => stands.length;
  int get occupiedStandsCount =>
      stands.where((s) => s.status == StandStatus.occupied).length;
  int get availableStandsCount =>
      stands.where((s) => s.status == StandStatus.available).length;

  double get occupancyPercentage {
    if (totalStands == 0) return 0.0;
    return (occupiedStandsCount / totalStands) * 100;
  }

  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    List<Stand>? stands,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      stands: stands ?? this.stands,
    );
  }
}
