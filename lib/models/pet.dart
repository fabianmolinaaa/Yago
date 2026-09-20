import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

enum YagoPetStatus {
  lost,
  found,
  reunited,
  community,
  urgent,
  isNew,
  mating,
}

class Pet {
  final String id;
  final String? ownerId;
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
  final bool _explicitUserOwner;
  final String? storyText;

  const Pet({
    required this.id,
    this.ownerId,
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
    bool isUserOwner = false,
    this.storyText,
  }) : _explicitUserOwner = isUserOwner;

  bool get isUserOwner {
    final currentUid = AuthService().currentUser?.uid;
    if (currentUid != null && ownerId != null && ownerId!.isNotEmpty) {
      return ownerId == currentUid;
    }
    return _explicitUserOwner;
  }

  /// Detalle resumido para PetCard (ej: "Golden Retriever · Macho · 2 años")
  String get detailsSummary => '$breed · $gender · $age';

  /// Ubicación y tiempo para PetCard (ej: "Palermo, CABA · Hace 2 horas")
  String get locationAndTime => '$location · $timeAgo';

  static YagoPetStatus parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'lost':
        return YagoPetStatus.lost;
      case 'found':
        return YagoPetStatus.found;
      case 'reunited':
        return YagoPetStatus.reunited;
      case 'community':
        return YagoPetStatus.community;
      case 'urgent':
        return YagoPetStatus.urgent;
      case 'mating':
        return YagoPetStatus.mating;
      case 'isNew':
        return YagoPetStatus.isNew;
      default:
        return YagoPetStatus.lost;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'species': species,
      'gender': gender,
      'age': age,
      'status': status.name,
      'location': location,
      'locationName': location,
      'timeAgo': timeAgo,
      'date': Timestamp.fromDate(date),
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'latitude': latitude,
      'longitude': longitude,
      'isUserOwner': isUserOwner,
      'storyText': storyText,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
    }

    return Pet(
      id: map['id'] ?? docId,
      ownerId: map['ownerId'] as String?,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      species: map['species'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? '',
      status: parseStatus(map['status']),
      location: map['location'] ?? map['locationName'] ?? '',
      timeAgo: map['timeAgo'] ?? '',
      date: parsedDate,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      contactName: map['contactName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? -34.5889,
      longitude: (map['longitude'] as num?)?.toDouble() ?? -58.4233,
      isUserOwner: map['isUserOwner'] as bool? ?? false,
      storyText: map['storyText'] as String?,
    );
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pet.fromMap(data, doc.id);
  }

  Pet copyWith({
    String? id,
    String? ownerId,
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
      ownerId: ownerId ?? this.ownerId,
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
