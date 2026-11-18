import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/ai_analysis.dart';
import '../models/chat_conversation.dart';
import '../models/feed_post.dart';
import '../models/moderation_report.dart';
import '../models/pet.dart';
import '../utils/time_utils.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class MockDataService extends ChangeNotifier {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;

  final Set<String> _bookmarkedPetIds = {};
  final List<Pet> _pets = [];
  final List<FeedPost> _communityPosts = [];
  final Map<String, DirectChatConversation> _chatConversations = {};
  final List<AiPetAnalysis> _aiAnalyses = [];
  final Map<String, String?> _userAvatarsByUid = {};
  final Map<String, String?> _userAvatarsByName = {};
  final List<ModerationReport> _moderationReports = [];
  final Set<String> _blockedUserKeys = {};

  List<ModerationReport> get moderationReports => List.unmodifiable(_moderationReports);
  Set<String> get blockedUserKeys => Set.unmodifiable(_blockedUserKeys);

  StreamSubscription<Set<String>>? _savedItemsSub;
  StreamSubscription<List<DirectChatConversation>>? _chatsSub;
  String? _subscribedUid;
  bool _initialChatsLoaded = false;
  String? _activeOpenChatId;

  /// Registra el ID de la conversación actualmente abierta en pantalla (o null al salir).
  void setActiveOpenChat(String? chatId) {
    _activeOpenChatId = chatId;
  }

  MockDataService._internal() {
    _init();
  }

  void _init() {
    if (!FirestoreService().isFirebaseReady) {
      // Carga inicial local para pruebas automatizadas (sin Firebase inicializado)
      _pets.addAll(FirestoreService().existingPets);
      _communityPosts.addAll(FirestoreService().existingCommunityPosts);
      return;
    }

    // Sincronización reactiva con Cloud Firestore (admite colecciones vacías)
    refreshFromFirestore().catchError((_) {});

    FirestoreService().streamPets().listen((pets) {
      _pets.clear();
      _pets.addAll(pets);
      notifyListeners();
    }, onError: (_) {});

    FirestoreService().streamFeedPosts().listen((posts) {
      _communityPosts.clear();
      _communityPosts.addAll(posts);
      notifyListeners();
    }, onError: (_) {});

    FirestoreService().streamAllUserProfiles().listen((profiles) {
      final currentUid = AuthService().currentUser?.uid;
      for (final profile in profiles) {
        final photo = (profile.photoUrl != null &&
                profile.photoUrl!.trim().isNotEmpty)
            ? profile.photoUrl!.trim()
            : null;
        if (profile.uid.isNotEmpty) {
          _userAvatarsByUid[profile.uid] = photo;
        }
        final normName = profile.displayName.trim().toLowerCase();
        if (normName.isNotEmpty) {
          _userAvatarsByName[normName] = photo;
        }
        if (currentUid != null && profile.uid == currentUid) {
          _userCustomPhotoUrl = photo;
        }
      }
      notifyListeners();
    }, onError: (_) {});

    // Escuchar cambios de sesión para re-suscribir los chats del usuario activo
    AuthService().authStateChanges.listen((user) {
      if (user == null) {
        _savedItemsSub?.cancel();
        _chatsSub?.cancel();
        _subscribedUid = null;
      } else {
        ensureUserSubscriptions(
          userId: user.uid,
          userName: user.displayName,
        );
        refreshFromFirestore().catchError((_) {});
      }
    }, onError: (_) {});

    ensureUserSubscriptions();
  }

  /// Asegura que los streams reactivos de guardados y chats estén suscritos al usuario actual
  void ensureUserSubscriptions({String? userId, String? userName}) {
    if (!FirestoreService().isFirebaseReady) return;
    final currentUser = AuthService().currentUser;
    final uid = userId ?? currentUser?.uid;
    final resolvedName = userName ??
        ((currentUser?.displayName?.trim().isNotEmpty == true)
            ? currentUser!.displayName!.trim()
            : currentUser?.email?.split('@').first);

    if (uid == null || uid.isEmpty) {
      _savedItemsSub?.cancel();
      _chatsSub?.cancel();
      _subscribedUid = null;
      _initialChatsLoaded = false;
      NotificationService().clearNotifications();
      return;
    }

    if (_subscribedUid == uid && _chatsSub != null) return;

    _savedItemsSub?.cancel();
    _chatsSub?.cancel();
    _subscribedUid = uid;
    _initialChatsLoaded = false;

    _savedItemsSub = FirestoreService().streamSavedItemIds(uid).listen((savedIds) {
      _bookmarkedPetIds.clear();
      _bookmarkedPetIds.addAll(savedIds);
      notifyListeners();
    }, onError: (_) {});

    _chatsSub = FirestoreService()
        .streamChatConversations(uid, userName: resolvedName)
        .listen((chats) {
      int newlyArrived = 0;
      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      final isAppResumed =
          lifecycleState == null || lifecycleState == AppLifecycleState.resumed;

      if (_initialChatsLoaded) {
        for (final chat in chats) {
          if (chat.isSelfChatFor(uid) ||
              chat.isDeletedFor(uid) ||
              isConversationBlocked(chat, uid)) {
            continue;
          }
          final isActivelyReadingThisChat =
              isAppResumed && _activeOpenChatId == chat.id;
          if (isActivelyReadingThisChat) continue;

          final prev = _chatConversations[chat.id];
          final fromOther = chat.lastMessageSenderId.isNotEmpty &&
              chat.lastMessageSenderId != uid;
          if (!fromOther) continue;

          if (prev == null && chat.unreadCount > 0) {
            newlyArrived += chat.unreadCount;
          } else if (prev != null && chat.unreadCount > prev.unreadCount) {
            newlyArrived += (chat.unreadCount - prev.unreadCount);
          } else if (prev != null &&
              chat.lastMessageAt.isAfter(prev.lastMessageAt) &&
              chat.unreadCount > 0) {
            newlyArrived += 1;
          }
        }
      }

      _chatConversations.clear();
      for (final chat in chats) {
        _chatConversations[chat.id] = chat;
      }
      _initialChatsLoaded = true;
      notifyListeners();

      final totalUnread = getTotalUnreadChatCount();
      if (newlyArrived > 0) {
        NotificationService().notifyIncomingDirectMessages(
          newMessagesCount: newlyArrived,
          totalUnreadCount: totalUnread,
        );
      } else if (totalUnread == 0 &&
          NotificationService().accumulatedMessagesCount > 0) {
        NotificationService().clearNotifications();
      }
    }, onError: (_) {});
  }

  /// Recarga los datos desde Cloud Firestore
  Future<void> refreshFromFirestore() async {
    if (!FirestoreService().isFirebaseReady) return;
    try {
      ensureUserSubscriptions();

      final freshPets = await FirestoreService().getPets();
      _pets.clear();
      _pets.addAll(freshPets);

      final freshPosts = await FirestoreService().getFeedPosts();
      _communityPosts.clear();
      _communityPosts.addAll(freshPosts);

      final userProfiles = await FirestoreService().getAllUserProfiles();
      for (final profile in userProfiles) {
        final photo = (profile.photoUrl != null &&
                profile.photoUrl!.trim().isNotEmpty)
            ? profile.photoUrl!.trim()
            : null;
        if (profile.uid.isNotEmpty) {
          _userAvatarsByUid[profile.uid] = photo;
        }
        final normName = profile.displayName.trim().toLowerCase();
        if (normName.isNotEmpty) {
          _userAvatarsByName[normName] = photo;
        }
      }

      final currentUser = AuthService().currentUser;
      final currentUid = currentUser?.uid;
      final currentName = (currentUser?.displayName?.trim().isNotEmpty == true)
          ? currentUser!.displayName!.trim()
          : currentUser?.email?.split('@').first;
      if (currentUid != null) {
        if (_userAvatarsByUid.containsKey(currentUid)) {
          _userCustomPhotoUrl = _userAvatarsByUid[currentUid];
        } else {
          final myProfile = await FirestoreService().getUserProfile(currentUid);
          if (myProfile != null) {
            final myPhoto = (myProfile.photoUrl != null &&
                    myProfile.photoUrl!.trim().isNotEmpty)
                ? myProfile.photoUrl!.trim()
                : null;
            _userCustomPhotoUrl = myPhoto;
            _userAvatarsByUid[currentUid] = myPhoto;
            final normMyName = myProfile.displayName.trim().toLowerCase();
            if (normMyName.isNotEmpty) {
              _userAvatarsByName[normMyName] = myPhoto;
            }
          }
        }
        final savedIds = await FirestoreService().getSavedItemIds(currentUid);
        _bookmarkedPetIds.clear();
        _bookmarkedPetIds.addAll(savedIds);

        final freshChats = await FirestoreService().getChatConversations(
          currentUid,
          userName: currentName,
        );
        _chatConversations.clear();
        for (final chat in freshChats) {
          _chatConversations[chat.id] = chat;
        }
      }
      notifyListeners();
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

  /// Obtiene los reportes creados por el usuario ordenados de más reciente a más antiguo
  List<Pet> getMyReports() {
    final reports = _pets.where((pet) => pet.isUserOwner).toList();
    reports.sort((a, b) => b.effectiveCreatedAt.compareTo(a.effectiveCreatedAt));
    return reports;
  }

  /// Agrega un nuevo reporte y lo persiste en Firestore
  Future<void> addPet(Pet pet) async {
    _pets.insert(0, pet);
    notifyListeners();
    try {
      await FirestoreService().addPet(pet);
    } catch (e) {
      _pets.removeWhere((p) => p.id == pet.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Elimina un reporte de mascota de la memoria y Firestore
  Future<void> deletePet(String petId) async {
    _pets.removeWhere((p) => p.id == petId);
    notifyListeners();
    try {
      await FirestoreService().deletePet(petId);
    } catch (e) {
      await refreshFromFirestore();
      rethrow;
    }
  }

  /// Marca una mascota como reunida / encontrada y actualiza Firestore
  void markAsReunited(String petId) {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(status: YagoPetStatus.reunited);
      notifyListeners();
      FirestoreService().markAsReunited(petId).catchError((_) {});
    }
  }

  /// Manejo de guardados / marcadores (soporta reportes de mascotas y publicaciones)
  bool isBookmarked(String itemId) => _bookmarkedPetIds.contains(itemId);

  void toggleBookmark(String itemId, {String? userId}) {
    final willBookmark = !_bookmarkedPetIds.contains(itemId);
    if (willBookmark) {
      _bookmarkedPetIds.add(itemId);
    } else {
      _bookmarkedPetIds.remove(itemId);
    }
    notifyListeners();

    final uid = userId ?? AuthService().currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final isPet = _pets.any((p) => p.id == itemId);
      FirestoreService()
          .toggleSaveItem(
            uid,
            itemId,
            isSaved: willBookmark,
            itemType: isPet ? 'pet' : 'post',
          )
          .catchError((_) {});
    }
  }

  /// Obtiene los reportes de mascotas guardados
  List<Pet> getSavedPets() {
    return _pets.where((pet) => _bookmarkedPetIds.contains(pet.id)).toList();
  }

  /// Obtiene las publicaciones comunitarias guardadas
  List<FeedPost> getSavedPosts() {
    return _communityPosts.where((post) => _bookmarkedPetIds.contains(post.id)).toList();
  }

  /// Posts comunitarios
  List<FeedPost> getCommunityPosts() => List.unmodifiable(_communityPosts);

  /// Obtiene los posts comunitarios del usuario autenticado ordenados de más reciente a más antiguo
  List<FeedPost> getMyPosts({String? userId, String? userName}) {
    if (userId == null && userName == null) return const [];
    final posts = _communityPosts.where((post) {
      if (userId != null && post.authorId != null && post.authorId!.isNotEmpty) {
        return post.authorId == userId;
      }
      if (userName != null && userName.trim().isNotEmpty) {
        return post.authorName.trim().toLowerCase() == userName.trim().toLowerCase();
      }
      return false;
    }).toList();
    posts.sort((a, b) {
      final dateA = a.createdAt ?? extractDateFromId(a.id) ?? DateTime(2020);
      final dateB = b.createdAt ?? extractDateFromId(b.id) ?? DateTime(2020);
      return dateB.compareTo(dateA);
    });
    return posts;
  }

  /// Agrega una nueva publicación comunitaria y la persiste en Firestore
  Future<void> addCommunityPost(FeedPost post) async {
    _communityPosts.insert(0, post);
    notifyListeners();
    try {
      await FirestoreService().addFeedPost(post);
    } catch (e) {
      _communityPosts.removeWhere((p) => p.id == post.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Elimina una publicación comunitaria de la memoria y Firestore
  Future<void> deleteCommunityPost(String postId) async {
    _communityPosts.removeWhere((p) => p.id == postId);
    notifyListeners();
    try {
      await FirestoreService().deleteFeedPost(postId);
    } catch (e) {
      await refreshFromFirestore();
      rethrow;
    }
  }

  /// Obtiene una publicación por su ID
  FeedPost? getFeedPostById(String id) {
    try {
      return _communityPosts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene un reporte de mascota por su ID
  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Alterna 'me gusta' en una publicación comunitaria vinculado a la cuenta actual y sincroniza con Firestore
  void togglePostLike(String postId, {String? userId}) {
    final currentAuthUid = AuthService().currentUser?.uid;
    final uid = userId ?? currentAuthUid ?? 'local-user';
    final index = _communityPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _communityPosts[index];
      final wasLiked = post.likedBy.contains(uid);
      final newIsLiked = !wasLiked;
      final updatedLikedBy = List<String>.from(post.likedBy);
      if (newIsLiked) {
        if (!updatedLikedBy.contains(uid)) updatedLikedBy.add(uid);
      } else {
        updatedLikedBy.remove(uid);
      }
      final newLikesCount = updatedLikedBy.length;

      _communityPosts[index] = post.copyWith(
        isLiked: newIsLiked,
        likedBy: updatedLikedBy,
        likesCount: newLikesCount,
      );
      notifyListeners();
      if (currentAuthUid != null || (userId != null && userId != 'local-user')) {
        FirestoreService()
            .togglePostLike(postId, userId: uid, isLiked: newIsLiked)
            .catchError((_) {});
      }
    }
  }

  /// Alterna 'me gusta' en un reporte/mascota vinculado a la cuenta actual y sincroniza con Firestore
  void togglePetLike(String petId, {String? userId}) {
    final currentAuthUid = AuthService().currentUser?.uid;
    final uid = userId ?? currentAuthUid ?? 'local-user';
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      final wasLiked = pet.likedBy.contains(uid);
      final newIsLiked = !wasLiked;
      final updatedLikedBy = List<String>.from(pet.likedBy);
      if (newIsLiked) {
        if (!updatedLikedBy.contains(uid)) updatedLikedBy.add(uid);
      } else {
        updatedLikedBy.remove(uid);
      }
      final newLikesCount = updatedLikedBy.length;

      _pets[index] = pet.copyWith(
        isLiked: newIsLiked,
        likedBy: updatedLikedBy,
        likesCount: newLikesCount,
      );
      notifyListeners();
      if (currentAuthUid != null || (userId != null && userId != 'local-user')) {
        FirestoreService()
            .togglePetLike(petId, userId: uid, isLiked: newIsLiked)
            .catchError((_) {});
      }
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

  /// Devuelve el avatar actual del usuario autenticado (priorizando el actualizado en sesión o Firestore)
  String? get currentUserAvatar {
    if (_userCustomPhotoUrl != null && _userCustomPhotoUrl!.trim().isNotEmpty) {
      return _userCustomPhotoUrl!.trim();
    }
    final currentUser = AuthService().currentUser;
    final uid = currentUser?.uid;
    if (uid != null && _userAvatarsByUid.containsKey(uid)) {
      final cached = _userAvatarsByUid[uid];
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    }
    final authPhoto = currentUser?.photoURL;
    if (authPhoto != null && authPhoto.trim().isNotEmpty) {
      return authPhoto.trim();
    }
    return null;
  }

  /// Resuelve el avatar actualizado para una publicación comunitaria en el feed
  String? resolvePostAuthorAvatar(FeedPost post) {
    if (post.isUserAuthor) {
      return currentUserAvatar ?? post.authorAvatar;
    }
    if (post.authorId != null &&
        post.authorId!.trim().isNotEmpty &&
        _userAvatarsByUid.containsKey(post.authorId!.trim())) {
      final cached = _userAvatarsByUid[post.authorId!.trim()];
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    }
    final normName = post.authorName.trim().toLowerCase();
    if (normName.isNotEmpty && _userAvatarsByName.containsKey(normName)) {
      final cached = _userAvatarsByName[normName];
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    }
    return post.authorAvatar;
  }

  /// Resuelve el avatar actualizado para un reporte o publicación de mascota en el feed
  String? resolvePetAuthorAvatar(Pet pet) {
    if (pet.isUserOwner) {
      return currentUserAvatar ?? pet.ownerAvatar;
    }
    if (pet.ownerId != null &&
        pet.ownerId!.trim().isNotEmpty &&
        _userAvatarsByUid.containsKey(pet.ownerId!.trim())) {
      final cached = _userAvatarsByUid[pet.ownerId!.trim()];
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    }
    final normName = pet.contactName.trim().toLowerCase();
    if (normName.isNotEmpty && _userAvatarsByName.containsKey(normName)) {
      final cached = _userAvatarsByName[normName];
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    }
    return pet.ownerAvatar;
  }

  void updateUserProfile({
    String? bio,
    String? location,
    String? phone,
    String? photoUrl,
    String? displayName,
    bool clearPhoto = false,
  }) {
    if (bio != null) _userBio = bio.trim();
    if (location != null) _userLocation = location.trim();
    if (phone != null) _userPhone = phone.trim();
    if (clearPhoto) {
      _userCustomPhotoUrl = null;
    } else if (photoUrl != null) {
      final cleanPhoto = photoUrl.trim();
      _userCustomPhotoUrl = cleanPhoto.isNotEmpty ? cleanPhoto : null;
    }

    final currentUser = AuthService().currentUser;
    final currentUid = currentUser?.uid;
    final effectiveName = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : currentUser?.displayName?.trim();

    if (currentUid != null && currentUid.isNotEmpty) {
      _userAvatarsByUid[currentUid] = _userCustomPhotoUrl;
    }
    if (effectiveName != null && effectiveName.isNotEmpty) {
      _userAvatarsByName[effectiveName.toLowerCase()] = _userCustomPhotoUrl;
    }

    // Propagar inmediatamente la foto y nombre actualizados a las publicaciones y reportes propios en memoria
    for (int i = 0; i < _communityPosts.length; i++) {
      final post = _communityPosts[i];
      if (post.isUserAuthor ||
          post.isUserAuthorFor(currentUid, userName: effectiveName)) {
        _communityPosts[i] = post.copyWith(
          authorName: effectiveName,
          authorAvatar: _userCustomPhotoUrl,
          clearAuthorAvatar: _userCustomPhotoUrl == null,
        );
      }
    }

    for (int i = 0; i < _pets.length; i++) {
      final pet = _pets[i];
      if (pet.isUserOwner ||
          pet.isUserOwnerFor(currentUid, userName: effectiveName)) {
        _pets[i] = pet.copyWith(
          contactName: effectiveName,
          ownerAvatar: _userCustomPhotoUrl,
          clearOwnerAvatar: _userCustomPhotoUrl == null,
        );
      }
    }

    notifyListeners();
  }

  void clearUserProfileCache() {
    _userBio = '';
    _userLocation = '';
    _userPhone = '';
    _userCustomPhotoUrl = null;
    _bookmarkedPetIds.clear();
    _chatConversations.clear();
    _aiAnalyses.clear();
    _blockedUserKeys.clear();
    notifyListeners();
  }

  /// Normaliza una clave de contacto por nombre para unificar conversaciones y bloqueos con una misma persona.
  static String normalizeContactKey(String? name) {
    if (name == null) return '';
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_áéíóúñü]'), '');
  }

  /// Verifica si una persona (por UID o por nombre) se encuentra bloqueada por el usuario actual.
  bool isPersonBlocked({String? userId, String? userName}) {
    if (userId != null && userId.trim().isNotEmpty) {
      if (_blockedUserKeys.contains(userId.trim())) return true;
    }
    final normName = normalizeContactKey(userName);
    if (normName.isNotEmpty) {
      if (_blockedUserKeys.contains('name:$normName')) return true;
    }
    return false;
  }

  /// Verifica si una conversación corresponde a un usuario bloqueado.
  bool isConversationBlocked(DirectChatConversation c, String currentUid) {
    if (c.isBlockedFor(currentUid) || c.isBlocked) return true;
    for (final pid in c.participantIds) {
      if (pid != currentUid && _blockedUserKeys.contains(pid)) {
        return true;
      }
    }
    final otherName = c.displayContactNameFor(
      currentUid,
      currentUserName: AuthService().currentUser?.displayName,
    );
    if (isPersonBlocked(userName: otherName)) {
      return true;
    }
    return false;
  }

  /// Busca si ya existe una conversación 1 a 1 con la misma persona (por UID real o nombre normalizado).
  DirectChatConversation? _findExistingChatWithPerson({
    required String currentUid,
    String? otherRealUid,
    required String contactName,
  }) {
    final normTargetName = normalizeContactKey(contactName);
    final currentUserName = AuthService().currentUser?.displayName;

    for (final conv in _chatConversations.values) {
      if (conv.isSelfChatFor(currentUid)) continue;

      if (otherRealUid != null &&
          otherRealUid.isNotEmpty &&
          !otherRealUid.startsWith('owner_') &&
          !otherRealUid.startsWith('author_')) {
        if (conv.participantIds.contains(otherRealUid)) {
          return conv;
        }
      }

      if (normTargetName.isNotEmpty) {
        final convContactName = conv.displayContactNameFor(
          currentUid,
          currentUserName: currentUserName,
        );
        if (normalizeContactKey(convContactName) == normTargetName) {
          return conv;
        }
        if (conv.participantNames.any(
          (n) =>
              normalizeContactKey(n) == normTargetName &&
              normalizeContactKey(n) != normalizeContactKey(currentUserName),
        )) {
          return conv;
        }
      }
    }
    return null;
  }

  List<ChatTopicContext> _mergeTopicContext(
    List<ChatTopicContext> existingContexts,
    ChatTopicContext newContext,
  ) {
    final mapById = <String, ChatTopicContext>{};
    for (final c in existingContexts) {
      if (c.itemId.isNotEmpty) {
        mapById[c.itemId] = c;
      }
    }
    if (newContext.itemId.isNotEmpty) {
      mapById[newContext.itemId] = newContext;
    }
    final list = mapById.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // ─── Gestión de Análisis IA y Chats Directos (Sprints 3 y 4: HU-S3-05, HU-S4-01 a HU-S4-05) ─

  List<AiPetAnalysis> getAiAnalyses() => List.unmodifiable(_aiAnalyses);

  void recordAiAnalysis(AiPetAnalysis analysis) {
    _aiAnalyses.insert(0, analysis);
    notifyListeners();
    FirestoreService().saveAiAnalysis(analysis).catchError((_) {});
  }

  /// Devuelve las conversaciones ordenadas cronológicamente (HU-S4-01).
  /// Por defecto excluye las archivadas; si [onlyArchived] es true devuelve solo las archivadas.
  List<DirectChatConversation> getChatConversations({
    bool includeArchived = false,
    bool onlyArchived = false,
  }) {
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final list = _chatConversations.values.where((c) {
      if (c.isSelfChatFor(currentUid)) return false;
      if (c.isDeletedFor(currentUid)) return false;
      if (isConversationBlocked(c, currentUid)) return false;
      final archived = c.isArchivedFor(currentUid);
      if (onlyArchived) return archived;
      if (!includeArchived && archived) return false;
      return true;
    }).toList();
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  }

  /// Cantidad de conversaciones archivadas por el usuario actual.
  int getArchivedConversationsCount() {
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    return _chatConversations.values
        .where((c) =>
            !c.isSelfChatFor(currentUid) &&
            !c.isDeletedFor(currentUid) &&
            !isConversationBlocked(c, currentUid) &&
            c.isArchivedFor(currentUid))
        .length;
  }

  DirectChatConversation? getChatById(String chatId) =>
      _chatConversations[chatId];

  /// Actualiza en tiempo real la lista de mensajes de una conversación activa desde el stream de subcolección.
  void updateChatMessagesFromStream(
    String chatId,
    List<DirectChatMessage> streamedMessages,
  ) {
    final existing = _chatConversations[chatId];
    if (existing == null) return;
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    if (isConversationBlocked(existing, currentUid)) return;
    List<DirectChatMessage> visible = streamedMessages;
    if (existing.clearedAtByUser.containsKey(currentUid)) {
      final clearedAt = existing.clearedAtByUser[currentUid]!;
      visible = streamedMessages
          .where((m) => m.sentAt.isAfter(clearedAt))
          .toList();
    }
    _chatConversations[chatId] = existing.copyWith(messages: visible);
    notifyListeners();
  }

  /// Total de mensajes no leídos en toda la bandeja de chats activos (HU-S4-05).
  int getTotalUnreadChatCount() {
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    int total = 0;
    for (final chat in _chatConversations.values) {
      if (!chat.isSelfChatFor(currentUid) &&
          !chat.isDeletedFor(currentUid) &&
          !isConversationBlocked(chat, currentUid) &&
          !chat.isArchivedFor(currentUid)) {
        total += chat.unreadCount;
      }
    }
    return total;
  }

  /// Cantidad de conversaciones activas que poseen al menos un mensaje sin leer (HU-S4-05).
  int getUnreadConversationsCount() {
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    return _chatConversations.values
        .where((c) =>
            !c.isSelfChatFor(currentUid) &&
            !c.isDeletedFor(currentUid) &&
            !isConversationBlocked(c, currentUid) &&
            !c.isArchivedFor(currentUid) &&
            c.unreadCount > 0)
        .length;
  }

  /// Obtiene o crea una conversación única de chat directo con el responsable de un reporte o publicación de mascota (HU-S3-05, HU-S4-02, HU-S4-04)
  DirectChatConversation getOrCreateChatForPet(
    Pet pet, {
    int? aiSimilarityPercentage,
    bool notify = true,
  }) {
    final currentUser = AuthService().currentUser;
    final currentUid = currentUser?.uid ?? 'local-user';
    final currentUserName =
        (currentUser?.displayName?.trim().isNotEmpty == true)
            ? currentUser!.displayName!.trim()
            : (currentUser?.email?.split('@').first ?? 'Usuario');
    final now = DateTime.now();
    final isCommunity = pet.status == YagoPetStatus.community;
    final resolvedContactName = isCommunity
        ? 'Equipo Yago'
        : (pet.contactName.isNotEmpty
            ? pet.contactName
            : 'Responsable del reporte');
    final realOwnerUid =
        (pet.ownerId != null && pet.ownerId!.trim().isNotEmpty)
            ? pet.ownerId!.trim()
            : null;
    final otherUid = realOwnerUid ??
        'contact_${normalizeContactKey(resolvedContactName).isNotEmpty ? normalizeContactKey(resolvedContactName) : pet.id}';
    final resolvedContactAvatar = resolvePetAuthorAvatar(pet);

    final newTopicContext = ChatTopicContext(
      isPostContext: false,
      itemId: pet.id,
      title: pet.name,
      imageUrl: pet.imageUrl,
      petStatus: pet.status,
      petBreed: pet.breed,
      petLocation: pet.location,
      aiSimilarityPercentage: aiSimilarityPercentage,
      updatedAt: now,
    );

    DirectChatConversation? existing = _findExistingChatWithPerson(
      currentUid: currentUid,
      otherRealUid: realOwnerUid,
      contactName: resolvedContactName,
    );
    if (existing == null) {
      for (final conv in _chatConversations.values) {
        if (!conv.isPostContext && conv.relatedPetId == pet.id) {
          existing = conv;
          break;
        }
      }
    }

    if (existing != null) {
      final mergedContexts = _mergeTopicContext(
        existing.effectiveContexts,
        newTopicContext,
      );
      final updatedParticipants = <String>{
        ...existing.participantIds,
        currentUid,
        otherUid,
      }.toList();
      final updatedNames = <String>{
        ...existing.participantNames,
        currentUserName.toLowerCase(),
        resolvedContactName.trim().toLowerCase(),
      }.toList();

      final updated = existing.copyWith(
        participantIds: updatedParticipants,
        participantNames: updatedNames,
        contactName: resolvedContactName,
        contactPhone: pet.contactPhone.isNotEmpty
            ? pet.contactPhone
            : existing.contactPhone,
        contactAvatar: resolvedContactAvatar ?? existing.contactAvatar,
        relatedPetId: pet.id,
        relatedPetName: pet.name,
        relatedPetImage: pet.imageUrl,
        relatedPetStatus: pet.status,
        relatedPetBreed: pet.breed,
        relatedPetLocation: pet.location,
        clearRelatedPostId: true,
        clearRelatedPostCategory: true,
        clearRelatedPostSnippet: true,
        aiSimilarityPercentage:
            aiSimilarityPercentage ?? existing.aiSimilarityPercentage,
        contexts: mergedContexts,
      );

      if (!isConversationBlocked(updated, currentUid)) {
        _chatConversations[existing.id] = updated;
        if (notify) {
          notifyListeners();
        }
        FirestoreService().saveChatConversation(updated).catchError((_) {});
      }
      return updated;
    }

    final personKey = realOwnerUid ??
        (normalizeContactKey(resolvedContactName).isNotEmpty
            ? normalizeContactKey(resolvedContactName)
            : pet.id);
    final chatId = 'chat_user_${personKey}_$currentUid';

    final created = DirectChatConversation(
      id: chatId,
      participantIds: [currentUid, otherUid],
      participantNames: [
        currentUserName.toLowerCase(),
        resolvedContactName.trim().toLowerCase(),
      ],
      participantDetails: {
        currentUid: {
          'displayName': currentUserName,
          'photoUrl': currentUserAvatar,
        },
        otherUid: {
          'displayName': resolvedContactName,
          'photoUrl': resolvedContactAvatar,
        },
      },
      contactName: resolvedContactName,
      contactPhone: pet.contactPhone,
      contactAvatar: resolvedContactAvatar,
      relatedPetId: pet.id,
      relatedPetName: pet.name,
      relatedPetImage: pet.imageUrl,
      relatedPetStatus: pet.status,
      relatedPetBreed: pet.breed,
      relatedPetLocation: pet.location,
      aiSimilarityPercentage: aiSimilarityPercentage,
      lastMessage: 'Chat directo iniciado',
      lastMessageSenderId: currentUid,
      lastMessageAt: now,
      unreadCount: 0,
      unreadCountByUser: {
        currentUid: 0,
        otherUid: 0,
      },
      blockedByUsers: isPersonBlocked(
        userId: realOwnerUid,
        userName: resolvedContactName,
      )
          ? [currentUid]
          : const [],
      contexts: [newTopicContext],
      messages: const [],
    );

    if ((pet.isUserOwner && currentUid != 'local-user') ||
        isConversationBlocked(created, currentUid)) {
      return created;
    }

    _chatConversations[chatId] = created;
    if (notify) {
      notifyListeners();
    }
    FirestoreService().saveChatConversation(created).catchError((_) {});
    return created;
  }

  /// Obtiene o crea una conversación única de chat directo con el autor de una publicación comunitaria (HU-S4-02, HU-S4-04)
  DirectChatConversation getOrCreateChatForPost(
    FeedPost post, {
    bool notify = true,
  }) {
    final currentUser = AuthService().currentUser;
    final currentUid = currentUser?.uid ?? 'local-user';
    final currentUserName =
        (currentUser?.displayName?.trim().isNotEmpty == true)
            ? currentUser!.displayName!.trim()
            : (currentUser?.email?.split('@').first ?? 'Usuario');
    final now = DateTime.now();
    final contactName =
        post.authorName.isNotEmpty ? post.authorName : 'Autor de publicación';
    final realAuthorUid =
        (post.authorId != null && post.authorId!.trim().isNotEmpty)
            ? post.authorId!.trim()
            : null;
    final otherUid = realAuthorUid ??
        'contact_${normalizeContactKey(contactName).isNotEmpty ? normalizeContactKey(contactName) : post.id}';
    final category = post.categoryTag ?? 'Comunidad';
    final snippet = post.displayContent;
    final resolvedAuthorAvatar = resolvePostAuthorAvatar(post);

    final newTopicContext = ChatTopicContext(
      isPostContext: true,
      itemId: post.id,
      title: category,
      imageUrl: post.imageUrl ?? '',
      petStatus: YagoPetStatus.community,
      petLocation: 'Feed comunitario',
      postCategory: category,
      postSnippet: snippet,
      updatedAt: now,
    );

    DirectChatConversation? existing = _findExistingChatWithPerson(
      currentUid: currentUid,
      otherRealUid: realAuthorUid,
      contactName: contactName,
    );
    if (existing == null) {
      for (final conv in _chatConversations.values) {
        if (conv.isPostContext && conv.relatedPostId == post.id) {
          existing = conv;
          break;
        }
      }
    }

    if (existing != null) {
      final mergedContexts = _mergeTopicContext(
        existing.effectiveContexts,
        newTopicContext,
      );
      final updatedParticipants = <String>{
        ...existing.participantIds,
        currentUid,
        otherUid,
      }.toList();
      final updatedNames = <String>{
        ...existing.participantNames,
        currentUserName.toLowerCase(),
        contactName.trim().toLowerCase(),
      }.toList();

      final updated = existing.copyWith(
        participantIds: updatedParticipants,
        participantNames: updatedNames,
        contactName: contactName,
        contactAvatar: resolvedAuthorAvatar ?? existing.contactAvatar,
        relatedPetId: post.id,
        relatedPetName: category,
        relatedPetImage: post.imageUrl ?? '',
        relatedPetStatus: YagoPetStatus.community,
        relatedPetBreed: '',
        relatedPetLocation: 'Feed comunitario',
        relatedPostId: post.id,
        relatedPostCategory: category,
        relatedPostSnippet: snippet,
        clearAiSimilarity: true,
        contexts: mergedContexts,
      );

      if (!isConversationBlocked(updated, currentUid)) {
        _chatConversations[existing.id] = updated;
        if (notify) {
          notifyListeners();
        }
        FirestoreService().saveChatConversation(updated).catchError((_) {});
      }
      return updated;
    }

    final personKey = realAuthorUid ??
        (normalizeContactKey(contactName).isNotEmpty
            ? normalizeContactKey(contactName)
            : post.id);
    final chatId = 'chat_user_${personKey}_$currentUid';

    final created = DirectChatConversation(
      id: chatId,
      participantIds: [currentUid, otherUid],
      participantNames: [
        currentUserName.toLowerCase(),
        contactName.trim().toLowerCase(),
      ],
      participantDetails: {
        currentUid: {
          'displayName': currentUserName,
          'photoUrl': currentUserAvatar,
        },
        otherUid: {
          'displayName': contactName,
          'photoUrl': resolvedAuthorAvatar,
        },
      },
      contactName: contactName,
      contactPhone: 'Contacto por chat interno',
      contactAvatar: resolvedAuthorAvatar,
      relatedPetId: post.id,
      relatedPetName: category,
      relatedPetImage: post.imageUrl ?? '',
      relatedPetStatus: YagoPetStatus.community,
      relatedPetLocation: 'Feed comunitario',
      relatedPostId: post.id,
      relatedPostCategory: category,
      relatedPostSnippet: snippet,
      lastMessage: 'Chat directo iniciado',
      lastMessageSenderId: currentUid,
      lastMessageAt: now,
      unreadCount: 0,
      unreadCountByUser: {
        currentUid: 0,
        otherUid: 0,
      },
      blockedByUsers: isPersonBlocked(
        userId: realAuthorUid,
        userName: contactName,
      )
          ? [currentUid]
          : const [],
      contexts: [newTopicContext],
      messages: const [],
    );

    if ((post.isUserAuthor && currentUid != 'local-user') ||
        isConversationBlocked(created, currentUid)) {
      return created;
    }

    _chatConversations[chatId] = created;
    if (notify) {
      notifyListeners();
    }
    FirestoreService().saveChatConversation(created).catchError((_) {});
    return created;
  }

  /// Cambia el contexto activo (mascota o publicación) dentro de una misma conversación con la misma persona.
  DirectChatConversation switchActiveChatContext(
    String chatId,
    ChatTopicContext contextTopic,
  ) {
    final existing = _chatConversations[chatId];
    if (existing == null) {
      throw StateError('No existe la conversación $chatId');
    }
    final now = DateTime.now();
    final updatedTopic = contextTopic.copyWith(updatedAt: now);
    final mergedContexts = _mergeTopicContext(
      existing.effectiveContexts,
      updatedTopic,
    );

    final updated = existing.copyWith(
      relatedPetId: updatedTopic.itemId,
      relatedPetName: updatedTopic.title,
      relatedPetImage: updatedTopic.imageUrl,
      relatedPetStatus: updatedTopic.petStatus,
      relatedPetBreed: updatedTopic.petBreed,
      relatedPetLocation: updatedTopic.petLocation,
      relatedPostId: updatedTopic.isPostContext ? updatedTopic.itemId : null,
      clearRelatedPostId: !updatedTopic.isPostContext,
      relatedPostCategory:
          updatedTopic.isPostContext ? updatedTopic.postCategory : null,
      clearRelatedPostCategory: !updatedTopic.isPostContext,
      relatedPostSnippet:
          updatedTopic.isPostContext ? updatedTopic.postSnippet : null,
      clearRelatedPostSnippet: !updatedTopic.isPostContext,
      aiSimilarityPercentage: updatedTopic.aiSimilarityPercentage,
      clearAiSimilarity: updatedTopic.aiSimilarityPercentage == null,
      contexts: mergedContexts,
    );

    _chatConversations[chatId] = updated;
    notifyListeners();
    FirestoreService().saveChatConversation(updated).catchError((_) {});
    return updated;
  }

  /// Envía un mensaje (texto y/o foto) dentro del chat directo y lo sincroniza con Firestore (HU-S3-05, HU-S4-03)
  DirectChatMessage sendDirectMessage(
    String chatId,
    String text, {
    String? senderName,
    String? imageUrl,
  }) {
    final currentUser = AuthService().currentUser;
    final uid = currentUser?.uid ?? 'local-user';
    final name = senderName ??
        ((currentUser?.displayName?.trim().isNotEmpty == true)
            ? currentUser!.displayName!.trim()
            : (currentUser?.email?.split('@').first ?? 'Tú'));
    final now = DateTime.now();
    final cleanText = text.trim();

    final existing = _chatConversations[chatId];
    final msg = DirectChatMessage(
      id: 'msg_${now.microsecondsSinceEpoch}',
      senderId: uid,
      senderName: name,
      text: cleanText,
      imageUrl: imageUrl,
      isRead: true,
      sentAt: now,
      contextItemId: existing != null
          ? (existing.isPostContext
              ? (existing.relatedPostId ?? existing.relatedPetId)
              : existing.relatedPetId)
          : null,
      contextTitle: existing != null
          ? (existing.isPostContext
              ? (existing.relatedPostCategory ?? 'Comunidad')
              : existing.relatedPetName)
          : null,
      contextImage: existing?.relatedPetImage,
      contextPetStatus: existing?.relatedPetStatus,
      contextIsPost: existing?.isPostContext ?? false,
      contextPostCategory: existing?.relatedPostCategory,
      contextAiSimilarity: existing?.aiSimilarityPercentage,
    );

    if (existing != null) {
      if (isConversationBlocked(existing, uid)) {
        return msg;
      }
      final updatedMessages = [...existing.messages, msg];
      final preview = cleanText.isNotEmpty
          ? cleanText
          : (imageUrl != null && imageUrl.isNotEmpty
              ? '📷 Foto adjunta'
              : 'Mensaje enviado');
      final otherParticipant = existing.participantIds.firstWhere(
        (id) => id != uid,
        orElse: () => '',
      );

      final updatedUnreadMap = Map<String, int>.from(existing.unreadCountByUser);
      updatedUnreadMap[uid] = 0;
      if (otherParticipant.isNotEmpty) {
        updatedUnreadMap[otherParticipant] =
            (updatedUnreadMap[otherParticipant] ?? 0) + 1;
      }

      final updatedDetails =
          Map<String, Map<String, dynamic>>.from(existing.participantDetails);
      updatedDetails[uid] = {
        'displayName': name,
        'photoUrl': currentUser?.photoURL ?? _userCustomPhotoUrl,
      };

      final updatedNames = <String>{
        ...existing.participantNames.map((e) => e.trim().toLowerCase()),
        if (name.toLowerCase() != 'tú') name.toLowerCase(),
      }.toList();

      final updatedChat = existing.copyWith(
        participantDetails: updatedDetails,
        participantNames: updatedNames,
        messages: updatedMessages,
        lastMessage: preview,
        lastMessageSenderId: uid,
        lastMessageAt: now,
        unreadCount: 0,
        unreadCountByUser: updatedUnreadMap,
        deletedByUsers: const [],
      );
      _chatConversations[chatId] = updatedChat;
      notifyListeners();
      FirestoreService()
          .addChatMessage(
            chatId,
            msg,
            recipientId: otherParticipant,
            conversation: updatedChat,
          )
          .catchError((_) {});
    }

    return msg;
  }

  /// Registra un mensaje entrante de la otra persona e incrementa el indicador de no leídos (HU-S4-03, HU-S4-05)
  DirectChatMessage? receiveDirectMessage(
    String chatId,
    String text, {
    String? senderId,
    String? senderName,
    String? imageUrl,
    DateTime? sentAt,
  }) {
    final existing = _chatConversations[chatId];
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final now = sentAt ?? DateTime.now();
    final resolvedSenderId = senderId ??
        existing?.participantIds.firstWhere(
          (id) => id != currentUid,
          orElse: () => 'contact_${chatId.hashCode}',
        ) ??
        'contact';
    final resolvedSenderName =
        senderName ?? existing?.contactName ?? 'Contacto';

    if (_blockedUserKeys.contains('chat:${chatId.trim()}') ||
        isPersonBlocked(
          userId: resolvedSenderId,
          userName: resolvedSenderName,
        ) ||
        (existing != null && isConversationBlocked(existing, currentUid))) {
      return null;
    }

    final cleanText = text.trim();

    final msg = DirectChatMessage(
      id: 'msg_in_${now.microsecondsSinceEpoch}',
      senderId: resolvedSenderId,
      senderName: resolvedSenderName,
      text: cleanText,
      imageUrl: imageUrl,
      isRead: false,
      sentAt: now,
      contextItemId: existing != null
          ? (existing.isPostContext
              ? (existing.relatedPostId ?? existing.relatedPetId)
              : existing.relatedPetId)
          : null,
      contextTitle: existing != null
          ? (existing.isPostContext
              ? (existing.relatedPostCategory ?? 'Comunidad')
              : existing.relatedPetName)
          : null,
      contextImage: existing?.relatedPetImage,
      contextPetStatus: existing?.relatedPetStatus,
      contextIsPost: existing?.isPostContext ?? false,
      contextPostCategory: existing?.relatedPostCategory,
      contextAiSimilarity: existing?.aiSimilarityPercentage,
    );

    if (existing != null) {
      final updatedMessages = [...existing.messages, msg];
      final newUnread = existing.unreadCount + 1;
      final preview = cleanText.isNotEmpty
          ? cleanText
          : (imageUrl != null && imageUrl.isNotEmpty
              ? '📷 Foto adjunta'
              : 'Nuevo mensaje');
      final updatedUnreadMap = Map<String, int>.from(existing.unreadCountByUser);
      updatedUnreadMap[currentUid] = newUnread;

      final updatedChat = existing.copyWith(
        messages: updatedMessages,
        lastMessage: preview,
        lastMessageSenderId: resolvedSenderId,
        lastMessageAt: now,
        unreadCount: newUnread,
        unreadCountByUser: updatedUnreadMap,
      );
      _chatConversations[chatId] = updatedChat;
      notifyListeners();
      NotificationService().notifyIncomingDirectMessages(
        newMessagesCount: 1,
        totalUnreadCount: getTotalUnreadChatCount(),
      );
      FirestoreService()
          .addChatMessage(
            chatId,
            msg,
            recipientId: currentUid,
            conversation: updatedChat,
          )
          .catchError((_) {});
    }

    return msg;
  }

  /// Marca como leídos todos los mensajes de una conversación (HU-S4-05).
  void markChatAsRead(String chatId, {bool notify = true}) {
    final existing = _chatConversations[chatId];
    if (existing == null) return;

    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final hasUnreadMsgs = existing.unreadCount > 0 ||
        existing.messages.any((m) => !m.isRead && m.senderId != currentUid);

    if (!hasUnreadMsgs) return;

    final updatedMessages = existing.messages.map((m) {
      if (!m.isRead && m.senderId != currentUid) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    final updatedUnreadMap = Map<String, int>.from(existing.unreadCountByUser);
    updatedUnreadMap[currentUid] = 0;

    _chatConversations[chatId] = existing.copyWith(
      unreadCount: 0,
      unreadCountByUser: updatedUnreadMap,
      messages: updatedMessages,
    );

    if (notify) {
      notifyListeners();
    }
    NotificationService().syncWithUnreadCount(getTotalUnreadChatCount());
    FirestoreService().markChatAsRead(chatId, currentUid).catchError((_) {});
  }

  /// Marca todas las conversaciones de la bandeja como leídas (HU-S4-05).
  void markAllChatsAsRead() {
    final ids = _chatConversations.keys.toList();
    for (final id in ids) {
      markChatAsRead(id, notify: false);
    }
    NotificationService().clearNotifications();
    notifyListeners();
  }

  /// Archiva o desarchiva una conversación para el usuario actual.
  bool toggleArchiveChat(String chatId) {
    final existing = _chatConversations[chatId];
    if (existing == null) return false;

    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final updatedArchived = List<String>.from(existing.archivedByUsers);
    final willArchive = !updatedArchived.contains(currentUid);
    if (willArchive) {
      updatedArchived.add(currentUid);
    } else {
      updatedArchived.remove(currentUid);
    }

    _chatConversations[chatId] = existing.copyWith(
      archivedByUsers: updatedArchived,
    );
    notifyListeners();
    FirestoreService()
        .toggleArchiveChat(chatId, currentUid, isArchived: willArchive)
        .catchError((_) {});
    return willArchive;
  }

  /// Vacía los mensajes de la conversación únicamente para el usuario actual.
  void clearChatForUser(String chatId) {
    final existing = _chatConversations[chatId];
    if (existing == null) return;

    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final now = DateTime.now();
    final updatedClearedAt = Map<String, DateTime>.from(existing.clearedAtByUser);
    updatedClearedAt[currentUid] = now;

    final updatedUnread = Map<String, int>.from(existing.unreadCountByUser);
    updatedUnread[currentUid] = 0;

    _chatConversations[chatId] = existing.copyWith(
      messages: const [],
      lastMessage: 'Chat vacío',
      unreadCount: 0,
      unreadCountByUser: updatedUnread,
      clearedAtByUser: updatedClearedAt,
    );
    NotificationService().syncWithUnreadCount(getTotalUnreadChatCount());
    notifyListeners();
    FirestoreService()
        .clearChatForUser(chatId, currentUid, now)
        .catchError((_) {});
  }

  /// Elimina una conversación de la bandeja de chats para el usuario actual.
  void deleteChatConversation(String chatId) {
    final currentUid = AuthService().currentUser?.uid;
    if (_chatConversations.remove(chatId) != null) {
      NotificationService().syncWithUnreadCount(getTotalUnreadChatCount());
      notifyListeners();
      FirestoreService()
          .deleteChatConversation(chatId, userId: currentUid)
          .catchError((_) {});
    }
  }

  /// Bloquea a una persona y quita inmediatamente todas sus conversaciones de la bandeja de chats,
  /// impidiendo recibir más mensajes de esa persona (HU-S5-01).
  void blockUserAndRemoveChat(
    String chatId, {
    String? blockedUserId,
    String? blockedUserName,
  }) {
    final currentUid = AuthService().currentUser?.uid ?? 'local-user';
    final existing = _chatConversations[chatId];

    final resolvedOtherId = (blockedUserId != null && blockedUserId.trim().isNotEmpty)
        ? blockedUserId.trim()
        : existing?.participantIds.firstWhere(
            (id) => id != currentUid,
            orElse: () => '',
          );
    final resolvedOtherName = (blockedUserName != null && blockedUserName.trim().isNotEmpty)
        ? blockedUserName.trim()
        : existing?.displayContactNameFor(
            currentUid,
            currentUserName: AuthService().currentUser?.displayName,
          );

    if (resolvedOtherId != null && resolvedOtherId.isNotEmpty) {
      _blockedUserKeys.add(resolvedOtherId);
    }
    final normName = normalizeContactKey(resolvedOtherName);
    if (normName.isNotEmpty) {
      _blockedUserKeys.add('name:$normName');
    }

    // Quitar de la bandeja cualquier conversación existente con esa persona
    final idsToRemove = <String>{chatId};
    for (final entry in _chatConversations.entries) {
      final conv = entry.value;
      if (resolvedOtherId != null &&
          resolvedOtherId.isNotEmpty &&
          conv.participantIds.contains(resolvedOtherId)) {
        idsToRemove.add(entry.key);
      } else if (normName.isNotEmpty) {
        final convName = conv.displayContactNameFor(
          currentUid,
          currentUserName: AuthService().currentUser?.displayName,
        );
        if (normalizeContactKey(convName) == normName) {
          idsToRemove.add(entry.key);
        }
      }
    }

    for (final id in idsToRemove) {
      _blockedUserKeys.add('chat:${id.trim()}');
      _chatConversations.remove(id);
      FirestoreService()
          .blockAndRemoveChatConversation(
            id,
            userId: currentUid,
            blockedUserId: resolvedOtherId,
          )
          .catchError((_) {});
    }

    NotificationService().syncWithUnreadCount(getTotalUnreadChatCount());
    notifyListeners();
  }

  /// Registra una denuncia comunitaria de moderación en el estado local (HU-S5-01)
  void addModerationReport(ModerationReport report) {
    _moderationReports.add(report);
    if (report.targetType == 'chat_message' || report.targetType == 'user') {
      blockUserAndRemoveChat(
        report.targetId,
        blockedUserId: report.targetAuthorId,
        blockedUserName: report.targetAuthorName,
      );
      return;
    }
    notifyListeners();
  }
}
