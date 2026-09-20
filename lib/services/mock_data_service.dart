import '../models/feed_post.dart';
import '../models/pet.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Set<String> _bookmarkedPetIds = {};

  final List<Pet> _pets = [
    Pet(
      id: 'pet-1',
      name: 'Luna',
      breed: 'Caniche',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.lost,
      location: 'Palermo, CABA',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          'Lleva un moño rosa en la cabeza. Se asustó en Plaza Armenia y salió corriendo hacia Av. Santa Fe. Es muy dócil pero asustadiza con ruidos fuertes.',
      imageUrl: 'assets/images/IMG_3508.JPG',
      tags: ['Moño rosa', 'Con chip', 'Pelaje blanco'],
      contactName: 'Camila Rodriguez',
      contactPhone: '+54 9 11 4567-8901',
      latitude: -34.5889,
      longitude: -58.4233,
      isUserOwner: true,
    ),
    Pet(
      id: 'pet-2',
      name: 'Rocky',
      breed: 'Mestizo de Labrador',
      species: '',
      gender: '',
      age: '2 años',
      status: YagoPetStatus.community,
      location: 'Costanera, Caleta Olivia',
      timeAgo: 'Hace 5 horas',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      description:
          'Paseando un rato...',
      imageUrl: 'assets/images/IMG_4178.JPG',
      tags: ['Pelaje negro', 'Pecho blanco', 'Muy sociable'],
      contactName: 'Equipo Yago',
      contactPhone: '+54 9 11 5566-7788',
      latitude: -34.5614,
      longitude: -58.4563,
    ),
    Pet(
      id: 'pet-mating-1',
      name: 'Simba',
      breed: 'Golden Retriever',
      species: 'Perro',
      gender: 'Macho',
      age: '3 años',
      status: YagoPetStatus.mating,
      location: 'Belgrano, CABA',
      timeAgo: 'Hace 4 horas',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      description:
          'Buscamos compañera para cruza. Excelente estado de salud, libreta sanitaria y vacunas completas al día. Certificado libre de displasia. Súper cariñoso y dócil.',
      imageUrl: 'assets/images/IMG_5370.JPG',
      tags: ['Pedigrí', 'Vacunas al día', 'Libre de displasia'],
      contactName: 'Martín Gómez',
      contactPhone: '+54 9 11 3456-7890',
      latitude: -34.5614,
      longitude: -58.4563,
    ),
    Pet(
      id: 'pet-3',
      name: 'Milo (Nombre asignado)',
      breed: 'Gato mestizo bicolor',
      species: 'Gato',
      gender: 'Macho',
      age: 'Joven (aprox 1 año)',
      status: YagoPetStatus.found,
      location: 'Recoleta, CABA',
      timeAgo: 'Ayer',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Encontrado merodeando en las escaleras de un edificio sobre Av. Las Heras. Es blanco con manchas coloradas en la cabeza y orejas. Muy mimoso y juguetón.',
      imageUrl: 'assets/images/IMG_2935.JPG',
      tags: ['Blanco y naranja', 'Sin collar', 'Cariñoso'],
      contactName: 'Lucía Fernández',
      contactPhone: '+54 9 11 9988-1122',
      latitude: -34.5875,
      longitude: -58.3974,
    ),
    Pet(
      id: 'pet-6',
      name: 'Luna',
      breed: 'Cachorra Mestiza',
      species: 'Perro',
      gender: 'Hembra',
      age: '1 año',
      status: YagoPetStatus.reunited,
      location: 'Barrio Patagonia',
      timeAgo: 'Hace 3 horas',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      description:
          'Gracias a todos los que colaboraron. Ya encontré a Luna!!!',
      imageUrl: 'assets/images/IMG_5667.JPG',
      tags: ['Reencuentro', 'Final feliz', 'En casa'],
      contactName: 'William Rodriguez',
      contactPhone: '+54 9 11 4567-8901',
      latitude: -34.5889,
      longitude: -58.4233,
      storyText:
          '¡Luna y William ya están juntos! Un vecino de la zona la reconoció gracias a la publicación en Yago y avisó de inmediato. Luna ya está descansando feliz con su familia.',
    ),
    Pet(
      id: 'pet-4',
      name: 'Thor',
      breed: 'Mestizo grande',
      species: 'Perro',
      gender: 'Macho',
      age: '3 años',
      status: YagoPetStatus.found,
      location: 'Caballito, CABA',
      timeAgo: 'Hace 1 día',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Encontrado acostado en la vereda cerca de Parque Rivadavia. Pelaje negro liso, contextura grande y collar verde agua. Manso y amigable con las personas.',
      imageUrl: 'assets/images/IMG_5370.JPG',
      tags: ['Collar verde', 'Pelaje negro', 'Tamaño grande'],
      contactName: 'Facundo Silva',
      contactPhone: '+54 9 11 2233-4455',
      latitude: -34.6186,
      longitude: -58.4352,
    ),
    Pet(
      id: 'pet-5',
      name: 'Luna',
      breed: 'Caniche',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.reunited,
      location: 'Núñez, CABA',
      timeAgo: 'Hace 2 minutos',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description:
          '¡Final feliz! Gracias a una vecina que la vio en el feed de Yago, Luna ya está de nuevo en casa, abrigada y descansando con su familia.',
      imageUrl: 'assets/images/IMG_5560.JPG',
      tags: ['Final feliz', 'Reunida', 'Abrigada'],
      contactName: 'Comunidad Yago',
      contactPhone: '+54 9 11 0000-0000',
      latitude: -34.5458,
      longitude: -58.4632,
      storyText:
          'Luna ya está segura y feliz en brazos de sus dueños. ¡Muchas gracias a todos los que compartieron!',
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

  /// Agrega una nueva publicación comunitaria
  void addCommunityPost(FeedPost post) {
    _communityPosts.insert(0, post);
  }

  /// Alterna 'me gusta' en una publicación comunitaria
  void togglePostLike(String postId) {
    final index = _communityPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _communityPosts[index];
      final newIsLiked = !post.isLiked;
      final newLikesCount = newIsLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
      _communityPosts[index] = post.copyWith(
        isLiked: newIsLiked,
        likesCount: newLikesCount,
      );
    }
  }
}
