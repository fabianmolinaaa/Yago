import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_analysis.dart';
import '../models/chat_conversation.dart';
import '../models/feed_post.dart';
import '../models/moderation_report.dart';
import '../models/pet.dart';
import '../models/user_model.dart';
import '../utils/time_utils.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Comprueba de forma segura si Firebase ha sido inicializado
  bool get isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _db {
    if (!isFirebaseReady) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _petsRef =>
      _db?.collection('pets');

  CollectionReference<Map<String, dynamic>>? get _postsRef =>
      _db?.collection('feed_posts');

  CollectionReference<Map<String, dynamic>>? get _usersRef =>
      _db?.collection('users');

  CollectionReference<Map<String, dynamic>>? get _chatsRef =>
      _db?.collection('chats');

  CollectionReference<Map<String, dynamic>>? get _aiScansRef =>
      _db?.collection('ai_scans');

  CollectionReference<Map<String, dynamic>>? get _moderationReportsRef =>
      _db?.collection('moderation_reports');

  /// Datos iniciales exactos existentes para el sembrado inicial en Firestore
  final List<Pet> existingPets = [
    Pet(
      id: 'pet-1',
      name: 'Luna',
      breed: 'Caniche',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.lost,
      location: 'Centro, El Gorosito, Caleta Olivia',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          'Lleva un moño rosa en la cabeza. Se asustó cerca del monumento al Gorosito y salió corriendo hacia Av. San Martín. Es muy dócil pero asustadiza con ruidos fuertes.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_caniche.jpg?alt=media&token=c423ae85-7535-49ca-ac88-110119309b7f',
      tags: const ['Moño rosa', 'Con chip', 'Pelaje blanco'],
      contactName: 'Camila Rodriguez',
      contactPhone: '+54 9 297 456-7890',
      latitude: -46.4385,
      longitude: -67.5278,
      ownerId: 'seed-camila-rodriguez',
      isUserOwner: false,
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
      description: 'Paseando un rato...',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Frocky_labrador.jpg?alt=media&token=f02b9044-ce93-4688-885f-a368f57f23d0',
      tags: const ['Pelaje negro', 'Pecho blanco', 'Muy sociable'],
      contactName: 'Equipo Yago',
      contactPhone: '+54 9 297 556-7788',
      latitude: -46.4348,
      longitude: -67.5182,
    ),
    Pet(
      id: 'pet-mating-1',
      name: 'Simba',
      breed: 'Golden Retriever',
      species: 'Perro',
      gender: 'Macho',
      age: '3 años',
      status: YagoPetStatus.mating,
      location: 'Barrio Parque, Caleta Olivia',
      timeAgo: 'Hace 4 horas',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      description:
          'Buscamos compañera para cruza. Excelente estado de salud, libreta sanitaria y vacunas completas al día. Certificado libre de displasia. Súper cariñoso y dócil.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fsimba_golden.jpg?alt=media&token=9c6b56dc-c05e-4ef7-9b23-7a00daf0e1f5',
      tags: const ['Pedigrí', 'Vacunas al día', 'Libre de displasia'],
      contactName: 'Martín Gómez',
      contactPhone: '+54 9 297 345-6789',
      latitude: -46.4425,
      longitude: -67.5245,
    ),
    Pet(
      id: 'pet-3',
      name: 'Milo (Nombre asignado)',
      breed: 'Gato mestizo bicolor',
      species: 'Gato',
      gender: 'Macho',
      age: 'Joven (aprox 1 año)',
      status: YagoPetStatus.found,
      location: 'Barrio Miramar, Caleta Olivia',
      timeAgo: 'Ayer',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Encontrado merodeando cerca de la plaza de Barrio Miramar. Es blanco con manchas coloradas en la cabeza y orejas. Muy mimoso y juguetón.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fmilo_gato.jpg?alt=media&token=bbf9da6a-3f5b-492d-984f-57bcebae6f5f',
      tags: const ['Blanco y naranja', 'Sin collar', 'Cariñoso'],
      contactName: 'Lucía Fernández',
      contactPhone: '+54 9 297 998-1122',
      latitude: -46.4478,
      longitude: -67.5150,
    ),
    Pet(
      id: 'pet-6',
      name: 'Luna',
      breed: 'Cachorra Mestiza',
      species: 'Perro',
      gender: 'Hembra',
      age: '1 año',
      status: YagoPetStatus.reunited,
      location: 'Barrio Patagonia, Caleta Olivia',
      timeAgo: 'Hace 3 horas',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      description:
          'Gracias a todos los que colaboraron. Ya encontré a Luna en Barrio Patagonia!!!',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_reunida.jpg?alt=media&token=04efce98-a4fa-426b-92b0-ef83b53621f0',
      tags: const ['Reencuentro', 'Final feliz', 'En casa'],
      contactName: 'William Rodriguez',
      contactPhone: '+54 9 297 456-7890',
      latitude: -46.4415,
      longitude: -67.5410,
      storyText:
          '¡Luna y William ya están juntos! Un vecino de Barrio Patagonia la reconoció gracias a la publicación en Yago y avisó de inmediato. Luna ya está descansando feliz con su familia.',
    ),
    Pet(
      id: 'pet-4',
      name: 'Thor',
      breed: 'Mestizo grande',
      species: 'Perro',
      gender: 'Macho',
      age: '3 años',
      status: YagoPetStatus.found,
      location: 'Barrio Gregores, Caleta Olivia',
      timeAgo: 'Hace 1 día',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description:
          'Encontrado acostado en la vereda cerca del complejo de Barrio Gregores. Pelaje negro liso, contextura grande y collar verde agua. Manso y amigable con las personas.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fthor_boyero.jpg?alt=media&token=a4bd0a7a-477e-4709-917c-b42c7202fba9',
      tags: const ['Collar verde', 'Pelaje negro', 'Tamaño grande'],
      contactName: 'Facundo Silva',
      contactPhone: '+54 9 297 223-4455',
      latitude: -46.4452,
      longitude: -67.5348,
    ),
    Pet(
      id: 'pet-5',
      name: 'Luna',
      breed: 'Caniche',
      species: 'Perro',
      gender: 'Hembra',
      age: '3 años',
      status: YagoPetStatus.reunited,
      location: 'Barrio 26 de Junio, Caleta Olivia',
      timeAgo: 'Hace 2 minutos',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description:
          '¡Final feliz! Gracias a una vecina de Barrio 26 de Junio que la vio en el feed de Yago, Luna ya está de nuevo en casa, abrigada y descansando con su familia.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_final_feliz.jpg?alt=media&token=9d19a6cf-4f32-40f7-9a8c-f8f7a19b2248',
      tags: const ['Final feliz', 'Reunida', 'Abrigada'],
      contactName: 'Comunidad Yago',
      contactPhone: '+54 9 297 000-0000',
      latitude: -46.4405,
      longitude: -67.5215,
      storyText:
          'Luna ya está segura y feliz en brazos de sus dueños. ¡Muchas gracias a todos los que compartieron en Caleta Olivia!',
    ),
  ];

  final List<FeedPost> existingCommunityPosts = const [
    FeedPost(
      id: 'post-1',
      authorName: 'Veterinaria San Roque',
      authorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      timeAgo: 'Hace 3 horas',
      content:
          '💡 Consejo de seguridad: Si tu mascota se extravía, mantén cerca una prenda con tu aroma cerca de la puerta o lugar de extravío. Su olfato es su mejor guía para volver.',
      likesCount: 0,
      commentsCount: 0,
    ),
    FeedPost(
      id: 'post-2',
      authorName: 'Refugio Patitas Solidarias',
      authorAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      timeAgo: 'Hace 1 día',
      content:
          'Jornada de castración y chipeo gratuito este fin de semana en la Unión Vecinal de Caleta Olivia. Cuidemos a nuestros compañeros.',
      likesCount: 0,
      commentsCount: 0,
    ),
  ];

  /// Comprueba si Firestore ya tiene datos; si no tiene, sube las publicaciones y reportes existentes tal cual están.
  Future<void> seedExistingData({bool force = false}) async {
    if (!isFirebaseReady || _db == null || _petsRef == null || _postsRef == null) {
      return;
    }

    try {
      final petsSnapshot = await _petsRef!.limit(1).get();
      if (petsSnapshot.docs.isEmpty || force) {
        final batch = _db!.batch();
        for (final pet in existingPets) {
          final docRef = _petsRef!.doc(pet.id);
          batch.set(docRef, pet.toMap(), SetOptions(merge: true));
        }
        await batch.commit();
      }

      final postsSnapshot = await _postsRef!.limit(1).get();
      if (postsSnapshot.docs.isEmpty || force) {
        final batch = _db!.batch();
        for (final post in existingCommunityPosts) {
          final docRef = _postsRef!.doc(post.id);
          batch.set(docRef, post.toMap(), SetOptions(merge: true));
        }
        await batch.commit();
      }
    } catch (_) {
      // Tolera desconexión o fallo de permisos
    }
  }

  Pet _ensureCaletaOlivia(Pet pet) {
    final loc = pet.location.toLowerCase();
    if (loc.contains('caba') ||
        loc.contains('palermo') ||
        loc.contains('recoleta') ||
        loc.contains('belgrano') ||
        loc.contains('caballito') ||
        loc.contains('núñez') ||
        loc.contains('nunez') ||
        loc.contains('buenos aires')) {
      String newLoc = 'Caleta Olivia, Santa Cruz';
      double newLat = -46.4348;
      double newLng = -67.5182;
      if (loc.contains('palermo')) {
        newLoc = 'Centro, El Gorosito, Caleta Olivia';
        newLat = -46.4385;
        newLng = -67.5278;
      } else if (loc.contains('recoleta')) {
        newLoc = 'Barrio Miramar, Caleta Olivia';
        newLat = -46.4478;
        newLng = -67.5150;
      } else if (loc.contains('belgrano')) {
        newLoc = 'Barrio Parque, Caleta Olivia';
        newLat = -46.4425;
        newLng = -67.5245;
      } else if (loc.contains('caballito')) {
        newLoc = 'Barrio Gregores, Caleta Olivia';
        newLat = -46.4452;
        newLng = -67.5348;
      } else if (loc.contains('n')) {
        newLoc = 'Barrio 26 de Junio, Caleta Olivia';
        newLat = -46.4405;
        newLng = -67.5215;
      }
      return pet.copyWith(
        location: newLoc,
        latitude: newLat,
        longitude: newLng,
      );
    }
    return pet;
  }

  /// Stream reactivo de mascotas ordenadas por fecha de creación del reporte (más recientes arriba)
  Stream<List<Pet>> streamPets({YagoPetStatus? status}) {
    if (!isFirebaseReady || _petsRef == null) {
      if (status == null) return Stream.value(List.from(existingPets));
      return Stream.value(existingPets.where((p) => p.status == status).toList());
    }

    Query<Map<String, dynamic>> query = _petsRef!;
    if (status != null) {
      query = _petsRef!.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => _ensureCaletaOlivia(Pet.fromFirestore(doc)))
          .where((p) => !p.isModerated)
          .toList();
      list.sort((a, b) => b.effectiveCreatedAt.compareTo(a.effectiveCreatedAt));
      return list;
    });
  }

  /// Obtiene la lista puntual de mascotas ordenadas por fecha de creación del reporte
  Future<List<Pet>> getPets({YagoPetStatus? status}) async {
    if (!isFirebaseReady || _petsRef == null) {
      final fallbackList = status == null
          ? List<Pet>.from(existingPets)
          : existingPets.where((p) => p.status == status).toList();
      fallbackList.sort((a, b) => b.effectiveCreatedAt.compareTo(a.effectiveCreatedAt));
      return fallbackList;
    }

    try {
      Query<Map<String, dynamic>> query = _petsRef!;
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      final snapshot = await query.get();
      final pets = snapshot.docs
          .map((doc) => _ensureCaletaOlivia(Pet.fromFirestore(doc)))
          .where((p) => !p.isModerated)
          .toList();
      pets.sort((a, b) => b.effectiveCreatedAt.compareTo(a.effectiveCreatedAt));
      return pets;
    } catch (_) {
      return [];
    }
  }

  /// Stream reactivo de publicaciones comunitarias
  Stream<List<FeedPost>> streamFeedPosts() {
    if (!isFirebaseReady || _postsRef == null) {
      return Stream.value(List.from(existingCommunityPosts));
    }

    return _postsRef!.snapshots().map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => FeedPost.fromFirestore(doc))
          .where((p) => !p.isModerated)
          .toList();
      posts.sort((a, b) {
        final aDate = a.createdAt ?? extractDateFromId(a.id) ?? DateTime(2020);
        final bDate = b.createdAt ?? extractDateFromId(b.id) ?? DateTime(2020);
        return bDate.compareTo(aDate);
      });
      return posts;
    });
  }

  /// Obtiene la lista puntual de publicaciones comunitarias
  Future<List<FeedPost>> getFeedPosts() async {
    if (!isFirebaseReady || _postsRef == null) {
      final fallbackList = List<FeedPost>.from(existingCommunityPosts);
      fallbackList.sort((a, b) {
        final aDate = a.createdAt ?? extractDateFromId(a.id) ?? DateTime(2020);
        final bDate = b.createdAt ?? extractDateFromId(b.id) ?? DateTime(2020);
        return bDate.compareTo(aDate);
      });
      return fallbackList;
    }

    try {
      final snapshot = await _postsRef!.get();
      final posts = snapshot.docs
          .map((doc) => FeedPost.fromFirestore(doc))
          .where((p) => !p.isModerated)
          .toList();
      posts.sort((a, b) {
        final aDate = a.createdAt ?? extractDateFromId(a.id) ?? DateTime(2020);
        final bDate = b.createdAt ?? extractDateFromId(b.id) ?? DateTime(2020);
        return bDate.compareTo(aDate);
      });
      return posts;
    } catch (_) {
      return [];
    }
  }

  /// Guarda una nueva mascota/reporte en Cloud Firestore
  Future<void> addPet(Pet pet) async {
    if (!isFirebaseReady || _petsRef == null) return;
    try {
      await _petsRef!.doc(pet.id).set(pet.toMap());
    } catch (e) {
      throw Exception('No se pudo guardar la mascota en Firestore: $e');
    }
  }

  /// Actualiza un reporte existente
  Future<void> updatePet(Pet pet) async {
    if (!isFirebaseReady || _petsRef == null) return;
    try {
      await _petsRef!.doc(pet.id).update(pet.toMap());
    } catch (e) {
      throw Exception('No se pudo actualizar el reporte: $e');
    }
  }

  /// Marca una mascota como reunida
  Future<void> markAsReunited(String petId, {String? storyText}) async {
    if (!isFirebaseReady || _petsRef == null) return;
    try {
      final Map<String, dynamic> updateData = {
        'status': YagoPetStatus.reunited.name,
        'isResolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
      };
      if (storyText != null && storyText.isNotEmpty) {
        updateData['storyText'] = storyText;
      }
      await _petsRef!.doc(petId).update(updateData);
    } catch (e) {
      throw Exception('Error al marcar como reunida: $e');
    }
  }

  /// Guarda una nueva publicación comunitaria
  Future<void> addFeedPost(FeedPost post) async {
    if (!isFirebaseReady || _postsRef == null) return;
    try {
      await _postsRef!.doc(post.id).set(post.toMap());
    } catch (e) {
      throw Exception('No se pudo guardar la publicación en Firestore: $e');
    }
  }

  /// Alterna 'me gusta' en una publicación comunitaria vinculado a cuentas reales
  Future<void> togglePostLike(
    String postId, {
    String? userId,
    bool? isLiked,
  }) async {
    if (!isFirebaseReady || _postsRef == null) return;
    try {
      final uid = userId ?? AuthService().currentUser?.uid;
      final docRef = _postsRef!.doc(postId);
      if (uid != null && uid.isNotEmpty) {
        if (isLiked == true) {
          await docRef.update({
            'likedBy': FieldValue.arrayUnion([uid]),
            'likesCount': FieldValue.increment(1),
          });
        } else if (isLiked == false) {
          await docRef.update({
            'likedBy': FieldValue.arrayRemove([uid]),
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          final snap = await docRef.get();
          final data = snap.data() ?? {};
          final likedBy = (data['likedBy'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          if (likedBy.contains(uid)) {
            await docRef.update({
              'likedBy': FieldValue.arrayRemove([uid]),
              'likesCount': FieldValue.increment(-1),
            });
          } else {
            await docRef.update({
              'likedBy': FieldValue.arrayUnion([uid]),
              'likesCount': FieldValue.increment(1),
            });
          }
        }
      } else if (isLiked != null) {
        await docRef.update({
          'likesCount': FieldValue.increment(isLiked ? 1 : -1),
          'isLiked': isLiked,
        });
      }
    } catch (_) {}
  }

  /// Alterna 'me gusta' en un reporte de mascota vinculado a cuentas reales
  Future<void> togglePetLike(
    String petId, {
    String? userId,
    bool? isLiked,
  }) async {
    if (!isFirebaseReady || _petsRef == null) return;
    try {
      final uid = userId ?? AuthService().currentUser?.uid;
      final docRef = _petsRef!.doc(petId);
      if (uid != null && uid.isNotEmpty) {
        if (isLiked == true) {
          await docRef.update({
            'likedBy': FieldValue.arrayUnion([uid]),
            'likesCount': FieldValue.increment(1),
          });
        } else if (isLiked == false) {
          await docRef.update({
            'likedBy': FieldValue.arrayRemove([uid]),
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          final snap = await docRef.get();
          final data = snap.data() ?? {};
          final likedBy = (data['likedBy'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          if (likedBy.contains(uid)) {
            await docRef.update({
              'likedBy': FieldValue.arrayRemove([uid]),
              'likesCount': FieldValue.increment(-1),
            });
          } else {
            await docRef.update({
              'likedBy': FieldValue.arrayUnion([uid]),
              'likesCount': FieldValue.increment(1),
            });
          }
        }
      } else if (isLiked != null) {
        await docRef.update({
          'likesCount': FieldValue.increment(isLiked ? 1 : -1),
          'isLiked': isLiked,
        });
      }
    } catch (_) {}
  }

  /// Elimina una publicación comunitaria de Firestore
  Future<void> deleteFeedPost(String postId) async {
    if (!isFirebaseReady || _postsRef == null) return;
    try {
      await _postsRef!.doc(postId).delete();
    } catch (e) {
      throw Exception('No se pudo eliminar la publicación de Firestore: $e');
    }
  }

  /// Elimina un reporte de mascota de Firestore
  Future<void> deletePet(String petId) async {
    if (!isFirebaseReady || _petsRef == null) return;
    try {
      await _petsRef!.doc(petId).delete();
    } catch (e) {
      throw Exception('No se pudo eliminar el reporte de Firestore: $e');
    }
  }

  // ─── Gestión de Perfiles de Usuario (/users) ─────────────────────────────

  /// Guarda o actualiza el documento de perfil de usuario en /users/{uid}
  Future<void> setUserProfile(UserModel user) async {
    if (!isFirebaseReady || _usersRef == null) return;
    try {
      await _usersRef!.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('No se pudo guardar el perfil de usuario: $e');
    }
  }

  /// Obtiene el perfil de un usuario desde Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    if (!isFirebaseReady || _usersRef == null) return null;
    try {
      final doc = await _usersRef!.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (_) {}
    return null;
  }

  /// Stream reactivo del perfil del usuario
  Stream<UserModel?> streamUserProfile(String uid) {
    if (!isFirebaseReady || _usersRef == null) {
      return Stream.value(null);
    }
    return _usersRef!.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Actualización parcial del perfil
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    if (!isFirebaseReady || _usersRef == null) return;
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      await _usersRef!.doc(uid).update(updateData);
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: $e');
    }
  }

  /// Stream reactivo de todos los perfiles de usuario para resolver avatares actualizados en el feed
  Stream<List<UserModel>> streamAllUserProfiles() {
    if (!isFirebaseReady || _usersRef == null) {
      return Stream.value(const []);
    }
    return _usersRef!.snapshots().map((snapshot) {
      return snapshot.docs.map(UserModel.fromFirestore).toList();
    });
  }

  /// Obtiene la lista de perfiles de usuario registrados
  Future<List<UserModel>> getAllUserProfiles() async {
    if (!isFirebaseReady || _usersRef == null) return const [];
    try {
      final snapshot = await _usersRef!.get();
      return snapshot.docs.map(UserModel.fromFirestore).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Sincroniza la foto de perfil y nombre actualizados del usuario en todas sus publicaciones y reportes de Firestore
  Future<void> syncUserAuthorMetadata({
    required String userId,
    String? userName,
    String? photoUrl,
  }) async {
    if (!isFirebaseReady || _db == null) return;
    final normName = userName?.trim().toLowerCase() ?? '';

    try {
      if (_postsRef != null) {
        final postsSnap = await _postsRef!.get();
        final batch = _db!.batch();
        int updates = 0;
        for (final doc in postsSnap.docs) {
          final data = doc.data();
          final authorId = (data['authorId'] as String?)?.trim() ?? '';
          final authorName =
              (data['authorName'] as String?)?.trim().toLowerCase() ?? '';
          final matches = (authorId.isNotEmpty && authorId == userId) ||
              (authorId.isEmpty && normName.isNotEmpty && authorName == normName);
          if (matches) {
            final updateMap = <String, dynamic>{
              'authorId': userId,
              'authorAvatar': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            };
            if (userName != null && userName.trim().isNotEmpty) {
              updateMap['authorName'] = userName.trim();
            }
            batch.update(doc.reference, updateMap);
            updates++;
          }
        }
        if (updates > 0) {
          await batch.commit();
        }
      }
    } catch (_) {}

    try {
      if (_petsRef != null) {
        final petsSnap = await _petsRef!.get();
        final batch = _db!.batch();
        int updates = 0;
        for (final doc in petsSnap.docs) {
          final data = doc.data();
          final ownerId = (data['ownerId'] as String?)?.trim() ?? '';
          final contactName =
              (data['contactName'] as String?)?.trim().toLowerCase() ?? '';
          final matches = (ownerId.isNotEmpty && ownerId == userId) ||
              (ownerId.isEmpty && normName.isNotEmpty && contactName == normName);
          if (matches) {
            final updateMap = <String, dynamic>{
              'ownerId': userId,
              'ownerAvatar': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            };
            if (userName != null && userName.trim().isNotEmpty) {
              updateMap['contactName'] = userName.trim();
            }
            batch.update(doc.reference, updateMap);
            updates++;
          }
        }
        if (updates > 0) {
          await batch.commit();
        }
      }
    } catch (_) {}
  }

  // ─── Guardados personales (/users/{uid}/saved_items) ─────────────────────

  /// Guarda o retira un elemento (mascota o post) de los guardados personales del usuario
  Future<void> toggleSaveItem(
    String uid,
    String itemId, {
    required bool isSaved,
    String itemType = 'item',
  }) async {
    if (!isFirebaseReady || _usersRef == null) return;
    try {
      final docRef = _usersRef!.doc(uid).collection('saved_items').doc(itemId);
      if (isSaved) {
        await docRef.set({
          'id': itemId,
          'itemType': itemType,
          'savedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (_) {}
  }

  /// Obtiene la lista de IDs de elementos guardados por el usuario
  Future<Set<String>> getSavedItemIds(String uid) async {
    if (!isFirebaseReady || _usersRef == null) return {};
    try {
      final snapshot =
          await _usersRef!.doc(uid).collection('saved_items').get();
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Stream reactivo de los IDs de elementos guardados
  Stream<Set<String>> streamSavedItemIds(String uid) {
    if (!isFirebaseReady || _usersRef == null) {
      return Stream.value({});
    }
    return _usersRef!
        .doc(uid)
        .collection('saved_items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  // ─── Análisis con IA (/ai_scans) y Chats Directos (/chats) ────────────────

  /// Registra el análisis fenotípico realizado con la cámara de IA (HU-S3-02)
  Future<void> saveAiAnalysis(AiPetAnalysis analysis) async {
    if (!isFirebaseReady || _aiScansRef == null) return;
    try {
      await _aiScansRef!
          .doc(analysis.id)
          .set(analysis.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Crea o actualiza el documento de conversación directa en /chats/{chatId} (HU-S3-05, HU-S4-01, HU-S4-02)
  Future<void> saveChatConversation(DirectChatConversation chat) async {
    if (!isFirebaseReady || _chatsRef == null) return;
    try {
      await _chatsRef!
          .doc(chat.id)
          .set(chat.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Agrega un mensaje en /chats/{chatId}/messages/{messageId} y actualiza lastMessage y unreadCount (HU-S4-03, HU-S4-05)
  Future<void> addChatMessage(
    String chatId,
    DirectChatMessage message, {
    String? recipientId,
    DirectChatConversation? conversation,
  }) async {
    if (!isFirebaseReady || _chatsRef == null) return;
    try {
      final chatRef = _chatsRef!.doc(chatId);
      final chatDoc = await chatRef.get();
      if (chatDoc.exists) {
        final blockedBy =
            List<String>.from(chatDoc.data()?['blockedByUsers'] ?? const []);
        if (blockedBy.isNotEmpty) {
          return;
        }
      }
      await chatRef
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      final previewText = message.text.trim().isNotEmpty
          ? message.text.trim()
          : (message.imageUrl != null && message.imageUrl!.isNotEmpty
              ? '📷 Foto adjunta'
              : '');

      final updateData = conversation != null
          ? Map<String, dynamic>.from(conversation.toMap())
          : <String, dynamic>{};

      updateData['lastMessage'] = previewText;
      updateData['lastMessageSenderId'] = message.senderId;
      updateData['lastMessageAt'] = Timestamp.fromDate(message.sentAt);
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      // Si alguien había eliminado el chat previamente, al recibir un nuevo mensaje vuelve a estar visible
      updateData['deletedByUsers'] = const <String>[];

      if (recipientId != null &&
          recipientId.isNotEmpty &&
          recipientId != message.senderId) {
        updateData['unreadCount'] = {
          recipientId: FieldValue.increment(1),
          message.senderId: 0,
        };
      } else {
        updateData['unreadCount'] = {
          message.senderId: 0,
        };
      }

      await chatRef.set(updateData, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Marca como leídos todos los mensajes pendientes de una conversación para el usuario actual (HU-S4-05)
  Future<void> markChatAsRead(String chatId, String userId) async {
    if (!isFirebaseReady || _chatsRef == null) return;
    try {
      final chatRef = _chatsRef!.doc(chatId);
      await chatRef.update({
        'unreadCount': {userId: 0},
        'unreadCountValue': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final unreadMsgs = await chatRef
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();
      if (unreadMsgs.docs.isNotEmpty && _db != null) {
        final batch = _db!.batch();
        for (final doc in unreadMsgs.docs) {
          final data = doc.data();
          if (data['senderId'] != userId) {
            batch.update(doc.reference, {'isRead': true});
          }
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  /// Archiva o desarchiva una conversación para el usuario actual
  Future<void> toggleArchiveChat(
    String chatId,
    String userId, {
    required bool isArchived,
  }) async {
    if (!isFirebaseReady || _chatsRef == null || userId.isEmpty) return;
    try {
      await _chatsRef!.doc(chatId).set({
        'archivedByUsers': isArchived
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Vacía el historial de mensajes de un chat únicamente para el usuario actual
  Future<void> clearChatForUser(
    String chatId,
    String userId,
    DateTime clearedAt,
  ) async {
    if (!isFirebaseReady || _chatsRef == null || userId.isEmpty) return;
    try {
      await _chatsRef!.doc(chatId).set({
        'clearedAtByUser': {
          userId: Timestamp.fromDate(clearedAt),
        },
        'unreadCount': {
          userId: 0,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Elimina una conversación de chat directo para el usuario actual (o de Firestore)
  Future<void> deleteChatConversation(
    String chatId, {
    String? userId,
  }) async {
    if (!isFirebaseReady || _chatsRef == null) return;
    try {
      if (userId != null && userId.isNotEmpty) {
        await _chatsRef!.doc(chatId).set({
          'deletedByUsers': FieldValue.arrayUnion([userId]),
          'unreadCount': {userId: 0},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _chatsRef!.doc(chatId).delete();
      }
    } catch (_) {}
  }

  /// Bloquea a la otra persona y elimina la conversación de la bandeja del usuario
  Future<void> blockAndRemoveChatConversation(
    String chatId, {
    String? userId,
    String? blockedUserId,
  }) async {
    if (!isFirebaseReady || _chatsRef == null) return;
    try {
      if (userId != null && userId.isNotEmpty) {
        await _chatsRef!.doc(chatId).set({
          'blockedByUsers': FieldValue.arrayUnion([userId]),
          'deletedByUsers': FieldValue.arrayUnion([userId]),
          'unreadCount': {userId: 0},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (_usersRef != null &&
            blockedUserId != null &&
            blockedUserId.isNotEmpty) {
          await _usersRef!.doc(userId).set({
            'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else {
        await _chatsRef!.doc(chatId).delete();
      }
    } catch (_) {}
  }

  bool _matchesUserChatDoc(
    Map<String, dynamic> data,
    String userId,
    String? userName,
  ) {
    final blockedBy = List<String>.from(data['blockedByUsers'] ?? const []);
    if (blockedBy.contains(userId)) return false;

    final deletedBy = List<String>.from(data['deletedByUsers'] ?? const []);
    if (deletedBy.contains(userId)) return false;

    final participants = List<String>.from(data['participantIds'] ?? const []);
    if (participants.contains(userId)) return true;

    final normUserName = userName?.trim().toLowerCase() ?? '';
    if (normUserName.isNotEmpty) {
      final participantNames =
          List<String>.from(data['participantNames'] ?? const [])
              .map((e) => e.trim().toLowerCase())
              .toList();
      if (participantNames.contains(normUserName)) return true;

      final docContactName =
          (data['contactName'] as String?)?.trim().toLowerCase() ?? '';
      if (docContactName == normUserName) return true;
    }

    return false;
  }

  /// Obtiene las conversaciones activas del usuario ordenadas cronológicamente (HU-S4-01)
  Future<List<DirectChatConversation>> getChatConversations(
    String userId, {
    String? userName,
  }) async {
    if (!isFirebaseReady || _chatsRef == null || userId.isEmpty) return [];
    try {
      final snapshot = await _chatsRef!.get();
      final result = <DirectChatConversation>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!_matchesUserChatDoc(data, userId, userName)) continue;

        final participants =
            List<String>.from(data['participantIds'] ?? const []);
        if (!participants.contains(userId)) {
          // Vincular automáticamente el UID real del reportante en Firestore
          doc.reference.set({
            'participantIds': FieldValue.arrayUnion([userId]),
          }, SetOptions(merge: true)).catchError((_) {});
        }

        final msgSnap = await doc.reference
            .collection('messages')
            .orderBy('sentAt')
            .get();
        final messages = msgSnap.docs
            .map((m) => DirectChatMessage.fromMap(m.data(), m.id))
            .toList();
        result.add(
          DirectChatConversation.fromMap(
            data,
            doc.id,
            messages: messages,
            currentUserId: userId,
            currentUserName: userName,
          ),
        );
      }
      result.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return result;
    } catch (_) {
      return [];
    }
  }

  /// Stream reactivo de conversaciones activas del usuario (HU-S4-01)
  Stream<List<DirectChatConversation>> streamChatConversations(
    String userId, {
    String? userName,
  }) {
    if (!isFirebaseReady || _chatsRef == null || userId.isEmpty) {
      return Stream.value(const []);
    }
    return _chatsRef!.snapshots().asyncMap((snapshot) async {
      final list = <DirectChatConversation>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!_matchesUserChatDoc(data, userId, userName)) continue;

        final participants =
            List<String>.from(data['participantIds'] ?? const []);
        if (!participants.contains(userId)) {
          doc.reference.set({
            'participantIds': FieldValue.arrayUnion([userId]),
          }, SetOptions(merge: true)).catchError((_) {});
        }

        List<DirectChatMessage> messages = const [];
        try {
          final msgSnap = await doc.reference
              .collection('messages')
              .orderBy('sentAt')
              .get();
          messages = msgSnap.docs
              .map((m) => DirectChatMessage.fromMap(m.data(), m.id))
              .toList();
        } catch (_) {}
        list.add(
          DirectChatConversation.fromMap(
            data,
            doc.id,
            messages: messages,
            currentUserId: userId,
            currentUserName: userName,
          ),
        );
      }
      list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return list;
    });
  }

  /// Stream reactivo de mensajes individuales de una conversación en tiempo real (HU-S4-03)
  Stream<List<DirectChatMessage>> streamChatMessages(String chatId) {
    if (!isFirebaseReady || _chatsRef == null || chatId.isEmpty) {
      return Stream.value(const []);
    }
    return _chatsRef!
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DirectChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Envía una denuncia comunitaria a moderación (HU-S5-01 / Sprint 5)
  Future<bool> submitModerationReport(ModerationReport report) async {
    try {
      if (isFirebaseReady && _moderationReportsRef != null) {
        final docRef = report.id.isNotEmpty
            ? _moderationReportsRef!.doc(report.id)
            : _moderationReportsRef!.doc();

        final finalReport = ModerationReport(
          id: docRef.id,
          reporterId: report.reporterId,
          reporterName: report.reporterName,
          reporterEmail: report.reporterEmail,
          targetType: report.targetType,
          targetId: report.targetId,
          targetTitle: report.targetTitle,
          targetAuthorId: report.targetAuthorId,
          targetAuthorName: report.targetAuthorName,
          reason: report.reason,
          reasonTitle: report.reasonTitle,
          description: report.description,
          status: report.status,
          reviewedBy: report.reviewedBy,
          createdAt: report.createdAt,
          resolvedAt: report.resolvedAt,
        );

        await docRef.set(finalReport.toMap());
        debugPrint('[HU-S5-01] Denuncia guardada en Firestore: ${docRef.id}');
        return true;
      } else {
        debugPrint('[HU-S5-01] Modo offline/mock: Denuncia registrada localmente.');
        return true;
      }
    } catch (e) {
      debugPrint('[HU-S5-01] Error al registrar denuncia en Firestore: $e');
      return false;
    }
  }
}
