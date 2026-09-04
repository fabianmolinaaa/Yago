import '../models/feed_post.dart';
import '../models/pet.dart';
import '../widgets/common/yago_badge.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Set<String> _bookmarkedPetIds = {};

  final List<Pet> _pets = [
    Pet(
      id: 'pet-1',
      name: 'Luna',
      breed: 'Lhasa Apso',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.lost,
      location: 'Palermo, CABA',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          'Se asustó con una moto en Plaza Armenia y salió corriendo hacia Av. Santa Fe. Es muy tímida con desconocidos pero responde a su nombre con tono suave.',
      imageUrl:
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
      tags: ['Collar rojo', 'Con chip', 'Oreja peluda'],
      contactName: 'Camila Rodriguez',
      contactPhone: '+54 9 11 4567-8901',
      latitude: -34.5889,
      longitude: -58.4233,
      isUserOwner: true,
    ),
    Pet(
      id: 'pet-2',
      name: 'Rocky',
      breed: 'Golden Retriever',
      species: 'Perro',
      gender: 'Macho',
      age: '2 años',
      status: YagoPetStatus.lost,
      location: 'Belgrano, CABA',
      timeAgo: 'Hace 5 horas',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      description:
          'Llevaba un arnés azul marino. Es muy juguetón y amigable con niños y otros perros. Se extravió cerca de Barrancas de Belgrano.',
      imageUrl:
          'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
      tags: ['Arnés azul', 'Pelaje dorado', 'Castaño'],
      contactName: 'Martín Gomez',
      contactPhone: '+54 9 11 5566-7788',
      latitude: -34.5614,
      longitude: -58.4563,
    ),
    Pet(
      id: 'pet-3',
      name: 'Milo (Nombre asignado)',
      breed: 'Siamés mestizo',
      species: 'Gato',
      gender: 'Macho',
      age: 'Joven (aprox 1 año)',
      status: YagoPetStatus.found,
      location: 'Recoleta, CABA',
      timeAgo: 'Ayer',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Encontrado merodeando en el patio interno de un edificio sobre Av. Las Heras. Tiene ojos celestes intensos, collar verde gastado sin chapa identificatoria.',
      imageUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      tags: ['Collar verde', 'Ojos celestes', 'Muy cariñoso'],
      contactName: 'Lucía Fernández',
      contactPhone: '+54 9 11 9988-1122',
      latitude: -34.5875,
      longitude: -58.3974,
    ),
    Pet(
      id: 'pet-4',
      name: 'Coco',
      breed: 'Beagle',
      species: 'Perro',
      gender: 'Macho',
      age: '4 años',
      status: YagoPetStatus.lost,
      location: 'Caballito, CABA',
      timeAgo: 'Hace 1 día',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Se perdió cerca de Parque Rivadavia. Tiene manchas tricolores típicas de la raza y una marca pequeña en el lomo derecho.',
      imageUrl:
          'https://images.unsplash.com/photo-1505628346881-b72b27e84530?auto=format&fit=crop&w=800&q=80',
      tags: ['Tricolor', 'Chapa identificatoria', 'Orejas caídas'],
      contactName: 'Facundo Silva',
      contactPhone: '+54 9 11 2233-4455',
      latitude: -34.6186,
      longitude: -58.4352,
    ),
    Pet(
      id: 'pet-5',
      name: 'Simona',
      breed: 'Gata Carey',
      species: 'Gato',
      gender: 'Hembra',
      age: 'Adulta',
      status: YagoPetStatus.found,
      location: 'Villa Urquiza, CABA',
      timeAgo: 'Hace 2 días',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description:
          'Resguardada en tránsito temporal. Fue encontrada mojada en una esquina de Triunvirato. Se encuentra en buen estado de salud, busca a su familia.',
      imageUrl:
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
      tags: ['Pelaje carey', 'Sin collar', 'Tránsito'],
      contactName: 'Romina Castro',
      contactPhone: '+54 9 11 3344-5566',
      latitude: -34.5732,
      longitude: -58.4878,
    ),
    Pet(
      id: 'pet-6',
      name: 'Toby',
      breed: 'Labrador Retriever',
      species: 'Perro',
      gender: 'Macho',
      age: '5 años',
      status: YagoPetStatus.reunited,
      location: 'Núñez, CABA',
      timeAgo: 'Hace 3 días',
      date: DateTime.now().subtract(const Duration(days: 3)),
      description:
          '¡Caso resuelto! Gracias a una vecina que vio la publicación en Yago, Toby se reencontró con su familia tras 48 horas de intensa búsqueda comunitaria.',
      imageUrl:
          'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?auto=format&fit=crop&w=800&q=80',
      tags: ['Final feliz', 'Reunido con su familia'],
      contactName: 'Comunidad Yago',
      contactPhone: '+54 9 11 0000-0000',
      latitude: -34.5458,
      longitude: -58.4632,
      storyText:
          'Toby ya está seguro en su casa descansando junto a sus dueños. ¡Gracias a toda la comunidad!',
    ),
  ];

  final List<FeedPost> _communityPosts = [
    const FeedPost(
      id: 'post-1',
      authorName: 'Veterinaria San Roque',
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      timeAgo: 'Hace 3 horas',
      content:
          '💡 Consejo de seguridad: Si tu mascota se extravía, mantén cerca una prenda con tu aroma cerca de la puerta o lugar de extravío. Su olfato es su mejor guía para volver.',
      likesCount: 34,
      commentsCount: 6,
    ),
    const FeedPost(
      id: 'post-2',
      authorName: 'Refugio Patitas Solidarias',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      timeAgo: 'Hace 1 día',
      content:
          'Jornada de castración y chipeo gratuito este fin de semana en Parque Chacabuco. Cuidemos a nuestros compañeros.',
      likesCount: 52,
      commentsCount: 12,
    ),
  ];

  /// Lista de todas las mascotas
  List<Pet> getAllPets() => List.unmodifiable(_pets);

  /// Filtra mascotas por estado
  List<Pet> getPetsByStatus(YagoPetStatus? status) {
    if (status == null) return getAllPets();
    return _pets.where((pet) => pet.status == status).toList();
  }

  /// Búsqueda y filtrado compuesto
  List<Pet> searchPets({
    required String query,
    String? species,
    YagoPetStatus? status,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _pets.where((pet) {
      final matchesQuery = cleanQuery.isEmpty ||
          pet.name.toLowerCase().contains(cleanQuery) ||
          pet.breed.toLowerCase().contains(cleanQuery) ||
          pet.location.toLowerCase().contains(cleanQuery) ||
          pet.tags.any((t) => t.toLowerCase().contains(cleanQuery));

      final matchesSpecies =
          species == null || species == 'Todos' || pet.species.toLowerCase() == species.toLowerCase();

      final matchesStatus = status == null || pet.status == status;

      return matchesQuery && matchesSpecies && matchesStatus;
    }).toList();
  }

  /// Obtiene los reportes creados por el usuario
  List<Pet> getMyReports() {
    return _pets.where((pet) => pet.isUserOwner).toList();
  }

  /// Agrega un nuevo reporte
  void addPet(Pet pet) {
    _pets.insert(0, pet);
  }

  /// Marca una mascota como reunida / encontrada
  void markAsReunited(String petId) {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(status: YagoPetStatus.reunited);
    }
  }

  /// Manejo de guardados / marcadores
  bool isBookmarked(String petId) => _bookmarkedPetIds.contains(petId);

  void toggleBookmark(String petId) {
    if (_bookmarkedPetIds.contains(petId)) {
      _bookmarkedPetIds.remove(petId);
    } else {
      _bookmarkedPetIds.add(petId);
    }
  }

  /// Posts comunitarios
  List<FeedPost> getCommunityPosts() => List.unmodifiable(_communityPosts);
}
