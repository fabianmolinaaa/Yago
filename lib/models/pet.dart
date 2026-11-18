import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../utils/time_utils.dart';

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
  final String? ownerAvatar;
  final String name;
  final String breed; // Raza, ej: "Golden Retriever", "Mestizo", "Siamés"
  final String species; // "Perro", "Gato", "Otro"
  final String gender; // "Macho", "Hembra"
  final String age; // ej: "2 años", "Cachorro", "Adulto"
  final YagoPetStatus status;
  final String location; // ej: "Palermo, CABA"
  final String timeAgo; // ej: "Hace 2 horas" (relativo a la fecha de pérdida/hallazgo)
  final DateTime date; // Fecha de pérdida o hallazgo indicada por el usuario
  final DateTime? createdAt; // Fecha real de creación/publicación del reporte en el sistema
  final String description;
  final String imageUrl;
  final List<String> tags; // ej: ["Collar rojo", "Con chip", "Mancha blanca"]
  final String contactName;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final bool _explicitUserOwner;
  final String? storyText;
  final bool isModerated;
  final int _explicitLikesCount;
  final List<String> likedBy;
  final bool _explicitIsLiked;

  const Pet({
    required this.id,
    this.ownerId,
    this.ownerAvatar,
    required this.name,
    required this.breed,
    required this.species,
    required this.gender,
    required this.age,
    required this.status,
    required this.location,
    required this.timeAgo,
    required this.date,
    this.createdAt,
    required this.description,
    required this.imageUrl,
    this.tags = const [],
    required this.contactName,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    bool isUserOwner = false,
    this.storyText,
    this.isModerated = false,
    int likesCount = 0,
    this.likedBy = const [],
    bool isLiked = false,
  })  : _explicitUserOwner = isUserOwner,
        _explicitLikesCount = likesCount,
        _explicitIsLiked = isLiked;

  int get likesCount =>
      likedBy.isNotEmpty ? likedBy.length : _explicitLikesCount;

  bool isUserOwnerFor(String? userId, {String? userName}) {
    if (userId != null && userId.isNotEmpty) {
      if (ownerId != null && ownerId == userId) {
        return true;
      }
      if (userName != null &&
          userName.trim().isNotEmpty &&
          contactName.trim().toLowerCase() == userName.trim().toLowerCase()) {
        return true;
      }
      return false;
    }
    if (userName != null &&
        userName.trim().isNotEmpty &&
        contactName.trim().toLowerCase() == userName.trim().toLowerCase()) {
      return true;
    }
    return _explicitUserOwner;
  }

  bool get isUserOwner {
    final user = AuthService().currentUser;
    return isUserOwnerFor(user?.uid, userName: user?.displayName);
  }


  bool get isLiked {
    final currentUid = AuthService().currentUser?.uid;
    if (currentUid != null) {
      return likedBy.contains(currentUid);
    }
    return _explicitIsLiked;
  }

  bool get isResolved => status == YagoPetStatus.reunited;

  /// Extrae los números de teléfono válidos y llamables asociados al reporte.
  /// Si quien reportó no ingresó un teléfono (ej. "Contacto por chat interno" o vacío),
  /// retorna una lista vacía.
  List<String> get callablePhones {
    if (status == YagoPetStatus.community) return const [];
    final raw = contactPhone.trim();
    if (raw.isEmpty) return const [];
    final lower = raw.toLowerCase();
    if (lower.contains('chat') ||
        lower.contains('sin tel') ||
        lower.contains('no especificado') ||
        lower.contains('desconocido')) {
      return const [];
    }
    final parts = raw.split('/');
    final valid = <String>[];
    for (final part in parts) {
      final clean = part.trim();
      final digits = clean.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6 && clean != '+54 9 297 000-0000') {
        valid.add(clean);
      }
    }
    return valid;
  }

  /// Indica si quien reportó agregó al menos un número de teléfono válido para llamar.
  bool get hasContactPhone => callablePhones.isNotEmpty;

  /// Primer número de teléfono válido para iniciar la llamada nativa.
  String? get primaryCallablePhone =>
      callablePhones.isNotEmpty ? callablePhones.first : null;

  /// Determina si un atributo opcional fue completado con un valor real
  /// (descartando cadenas vacías o marcadores como "Desconocido/a").
  static bool isKnownAttribute(String value) {
    final clean = value.trim().toLowerCase();
    if (clean.isEmpty) return false;
    const unknownValues = {
      'desconocido',
      'desconocida',
      'no especificado',
      'no especificada',
      'sin especificar',
      'no conozco la edad',
      'raza desconocida',
      'sin raza',
    };
    return !unknownValues.contains(clean);
  }

  bool get hasKnownBreed => isKnownAttribute(breed);

  /// Detalle resumido para PetCard en el feed: muestra únicamente los campos completados
  /// (raza, sexo, edad), omitiendo valores vacíos o "Desconocido/a".
  String get detailsSummary {
    final parts = <String>[
      if (isKnownAttribute(breed)) breed.trim(),
      if (isKnownAttribute(gender)) gender.trim(),
      if (isKnownAttribute(age)) age.trim(),
    ];
    return parts.join(' · ');
  }

  /// Fecha efectiva de creación del reporte en el sistema.
  /// Se utiliza para el orden cronológico en los feeds (los reportes recién publicados
  /// siempre aparecen primero sin importar si la fecha de extravío/hallazgo `date` es antigua).
  DateTime get effectiveCreatedAt =>
      createdAt ?? extractDateFromId(id) ?? date;

  /// Ubicación y tiempo de publicación para PetCard en el feed (ej: "Palermo, CABA · Recién publicado")
  String get locationAndTime =>
      '$location · ${formatTimeAgo(effectiveCreatedAt, fallback: timeAgo.isNotEmpty ? timeAgo : 'Reciente')}';

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
      'ownerAvatar': ownerAvatar,
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
      'isModerated': isModerated,
      'isResolved': status == YagoPetStatus.reunited,
      'likesCount': likedBy.isNotEmpty ? likedBy.length : likesCount,
      'likedBy': likedBy,
      'isLiked': isLiked,
      'createdAt': Timestamp.fromDate(effectiveCreatedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map, String docId) {
    final idStr = (map['id'] as String?) ?? docId;
    final idDate = extractDateFromId(idStr);

    DateTime parsedDate = DateTime.now();
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date'] as String) ?? DateTime.now();
    } else if (idDate != null) {
      parsedDate = idDate;
    }

    DateTime? parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt'] as String);
    }
    // Si el ID contiene el timestamp de creación y es más reciente que `createdAt`
    // (ej. reportes creados cuando `createdAt` copiaba la fecha antigua de extravío),
    // se prioriza la fecha real de creación del ID.
    if (idDate != null &&
        (parsedCreatedAt == null || idDate.isAfter(parsedCreatedAt))) {
      parsedCreatedAt = idDate;
    }

    final likedByList = (map['likedBy'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final rawLikesCount = (map['likesCount'] as num?)?.toInt() ?? 0;
    final actualLikesCount =
        likedByList.isNotEmpty ? likedByList.length : rawLikesCount;
    final currentUid = AuthService().currentUser?.uid;
    final isLikedCalculated = currentUid != null && likedByList.isNotEmpty
        ? likedByList.contains(currentUid)
        : (map['isLiked'] as bool? ?? false);

    return Pet(
      id: map['id'] ?? docId,
      ownerId: map['ownerId'] as String?,
      ownerAvatar: map['ownerAvatar'] as String?,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      species: map['species'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? '',
      status: parseStatus(map['status']),
      location: map['location'] ?? map['locationName'] ?? '',
      timeAgo: map['timeAgo'] ?? '',
      date: parsedDate,
      createdAt: parsedCreatedAt,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      contactName: map['contactName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? -34.5889,
      longitude: (map['longitude'] as num?)?.toDouble() ?? -58.4233,
      isUserOwner: map['isUserOwner'] as bool? ?? false,
      storyText: map['storyText'] as String?,
      isModerated: map['isModerated'] as bool? ?? false,
      likesCount: actualLikesCount,
      likedBy: likedByList,
      isLiked: isLikedCalculated,
    );
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pet.fromMap(data, doc.id);
  }

  Pet copyWith({
    String? id,
    String? ownerId,
    String? ownerAvatar,
    bool clearOwnerAvatar = false,
    String? name,
    String? breed,
    String? species,
    String? gender,
    String? age,
    YagoPetStatus? status,
    String? location,
    String? timeAgo,
    DateTime? date,
    DateTime? createdAt,
    String? description,
    String? imageUrl,
    List<String>? tags,
    String? contactName,
    String? contactPhone,
    double? latitude,
    double? longitude,
    bool? isUserOwner,
    String? storyText,
    bool? isModerated,
    int? likesCount,
    List<String>? likedBy,
    bool? isLiked,
  }) {
    final newLikedBy = likedBy ?? this.likedBy;
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerAvatar: clearOwnerAvatar ? null : (ownerAvatar ?? this.ownerAvatar),
      name: name ?? this.name,
      breed: breed ?? this.breed,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      status: status ?? this.status,
      location: location ?? this.location,
      timeAgo: timeAgo ?? this.timeAgo,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isUserOwner: isUserOwner ?? this.isUserOwner,
      storyText: storyText ?? this.storyText,
      isModerated: isModerated ?? this.isModerated,
      likesCount: likesCount ?? (likedBy != null ? newLikedBy.length : this.likesCount),
      likedBy: newLikedBy,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
