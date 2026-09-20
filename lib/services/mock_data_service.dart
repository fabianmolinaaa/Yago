import '../models/feed_post.dart';
import '../models/pet.dart';
import 'firestore_service.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;

  final Set<String> _bookmarkedPetIds = {};
  final List<Pet> _pets = [];
  final List<FeedPost> _communityPosts = [];

  MockDataService._internal() {
    _init();
  }

  void _init() {
    // Carga inicial local con los datos existentes
    _pets.addAll(FirestoreService().existingPets);
    _communityPosts.addAll(FirestoreService().existingCommunityPosts);

    // Sembrado y sincronización reactiva con Cloud Firestore
    refreshFromFirestore().catchError((_) {});

    FirestoreService().streamPets().listen((pets) {
      if (pets.isNotEmpty) {
        _pets.clear();
        _pets.addAll(pets);
      }
    }, onError: (_) {});

    FirestoreService().streamFeedPosts().listen((posts) {
      if (posts.isNotEmpty) {
        _communityPosts.clear();
        _communityPosts.addAll(posts);
      }
    }, onError: (_) {});
  }

  /// Recarga los datos desde Cloud Firestore
  Future<void> refreshFromFirestore() async {
    try {
      await FirestoreService().seedExistingData();
      final freshPets = await FirestoreService().getPets();
      if (freshPets.isNotEmpty) {
        _pets.clear();
        _pets.addAll(freshPets);
      }
      final freshPosts = await FirestoreService().getFeedPosts();
      if (freshPosts.isNotEmpty) {
        _communityPosts.clear();
        _communityPosts.addAll(freshPosts);
      }
    } catch (_) {}
  }

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

  /// Agrega un nuevo reporte y lo persiste en Firestore
  void addPet(Pet pet) {
    _pets.insert(0, pet);
    FirestoreService().addPet(pet).catchError((_) {});
  }

  /// Marca una mascota como reunida / encontrada y actualiza Firestore
  void markAsReunited(String petId) {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(status: YagoPetStatus.reunited);
      FirestoreService().markAsReunited(petId).catchError((_) {});
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

  /// Obtiene los posts comunitarios del usuario autenticado
  List<FeedPost> getMyPosts({String? userId, String? userName}) {
    if (userId == null && userName == null) return const [];
    return _communityPosts.where((post) {
      if (userId != null && post.authorId != null && post.authorId!.isNotEmpty) {
        return post.authorId == userId;
      }
      if (userName != null && userName.trim().isNotEmpty) {
        return post.authorName.trim().toLowerCase() == userName.trim().toLowerCase();
      }
      return false;
    }).toList();
  }

  /// Agrega una nueva publicación comunitaria y la persiste en Firestore
  void addCommunityPost(FeedPost post) {
    _communityPosts.insert(0, post);
    FirestoreService().addFeedPost(post).catchError((_) {});
  }

  /// Alterna 'me gusta' en una publicación comunitaria y sincroniza Firestore
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
      FirestoreService().togglePostLike(postId, newIsLiked).catchError((_) {});
    }
  }

  // ─── Gestión de Perfil de Usuario ──────────────────────────────────────────
  String _userBio = '';
  String _userLocation = '';
  String _userPhone = '';
  String? _userCustomPhotoUrl;

  String get userBio => _userBio;
  String get userLocation => _userLocation;
  String get userPhone => _userPhone;
  String? get userCustomPhotoUrl => _userCustomPhotoUrl;

  void updateUserProfile({
    String? bio,
    String? location,
    String? phone,
    String? photoUrl,
  }) {
    if (bio != null) _userBio = bio.trim();
    if (location != null) _userLocation = location.trim();
    if (phone != null) _userPhone = phone.trim();
    if (photoUrl != null) _userCustomPhotoUrl = photoUrl.trim();
  }

  void clearUserProfileCache() {
    _userBio = '';
    _userLocation = '';
    _userPhone = '';
    _userCustomPhotoUrl = null;
  }
}
