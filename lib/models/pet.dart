import '../widgets/common/yago_badge.dart';

class Pet {
  final String id;
  final String name;
  final String breed; // Raza, ej: "Golden Retriever", "Mestizo", "Siamés"
  final String species; // "Perro", "Gato", "Otro"
  final String gender; // "Macho", "Hembra"
  final String age; // ej: "2 años", "Cachorro", "Adulto"
  final YagoPetStatus status;
  final String location; // ej: "Palermo, CABA"
  final String timeAgo; // ej: "Hace 2 horas"
  final DateTime date;
  final String description;
  final String imageUrl;
  final List<String> tags; // ej: ["Collar rojo", "Con chip", "Mancha blanca"]
  final String contactName;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final bool isUserOwner;
  final String? storyText;

  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.species,
    required this.gender,
    required this.age,
    required this.status,
    required this.location,
    required this.timeAgo,
    required this.date,
    required this.description,
    required this.imageUrl,
    this.tags = const [],
    required this.contactName,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    this.isUserOwner = false,
    this.storyText,
  });

  /// Detalle resumido para PetCard (ej: "Golden Retriever · Macho · 2 años")
  String get detailsSummary => '$breed · $gender · $age';

  /// Ubicación y tiempo para PetCard (ej: "Palermo, CABA · Hace 2 horas")
  String get locationAndTime => '$location · $timeAgo';

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    String? species,
    String? gender,
    String? age,
    YagoPetStatus? status,
    String? location,
    String? timeAgo,
    DateTime? date,
    String? description,
    String? imageUrl,
    List<String>? tags,
    String? contactName,
    String? contactPhone,
    double? latitude,
    double? longitude,
    bool? isUserOwner,
    String? storyText,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      status: status ?? this.status,
      location: location ?? this.location,
      timeAgo: timeAgo ?? this.timeAgo,
      date: date ?? this.date,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isUserOwner: isUserOwner ?? this.isUserOwner,
      storyText: storyText ?? this.storyText,
    );
  }
}
