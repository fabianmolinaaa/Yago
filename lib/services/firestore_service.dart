import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/feed_post.dart';
import '../models/pet.dart';

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
      location: 'Palermo, CABA',
      timeAgo: 'Hace 2 horas',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          'Lleva un moño rosa en la cabeza. Se asustó en Plaza Armenia y salió corriendo hacia Av. Santa Fe. Es muy dócil pero asustadiza con ruidos fuertes.',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_caniche.jpg?alt=media&token=c423ae85-7535-49ca-ac88-110119309b7f',
      tags: const ['Moño rosa', 'Con chip', 'Pelaje blanco'],
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
      description: 'Paseando un rato...',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Frocky_labrador.jpg?alt=media&token=f02b9044-ce93-4688-885f-a368f57f23d0',
      tags: const ['Pelaje negro', 'Pecho blanco', 'Muy sociable'],
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
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fsimba_golden.jpg?alt=media&token=9c6b56dc-c05e-4ef7-9b23-7a00daf0e1f5',
      tags: const ['Pedigrí', 'Vacunas al día', 'Libre de displasia'],
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
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fmilo_gato.jpg?alt=media&token=bbf9da6a-3f5b-492d-984f-57bcebae6f5f',
      tags: const ['Blanco y naranja', 'Sin collar', 'Cariñoso'],
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
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_reunida.jpg?alt=media&token=04efce98-a4fa-426b-92b0-ef83b53621f0',
      tags: const ['Reencuentro', 'Final feliz', 'En casa'],
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
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fthor_boyero.jpg?alt=media&token=a4bd0a7a-477e-4709-917c-b42c7202fba9',
      tags: const ['Collar verde', 'Pelaje negro', 'Tamaño grande'],
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
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/yago-21b28.firebasestorage.app/o/reports%2Fluna_final_feliz.jpg?alt=media&token=9d19a6cf-4f32-40f7-9a8c-f8f7a19b2248',
      tags: const ['Final feliz', 'Reunida', 'Abrigada'],
      contactName: 'Comunidad Yago',
      contactPhone: '+54 9 11 0000-0000',
      latitude: -34.5458,
      longitude: -58.4632,
      storyText:
          'Luna ya está segura y feliz en brazos de sus dueños. ¡Muchas gracias a todos los que compartieron!',
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
      likesCount: 34,
      commentsCount: 6,
    ),
    FeedPost(
      id: 'post-2',
      authorName: 'Refugio Patitas Solidarias',
      authorAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      timeAgo: 'Hace 1 día',
      content:
          'Jornada de castración y chipeo gratuito este fin de semana en Parque Chacabuco. Cuidemos a nuestros compañeros.',
      likesCount: 52,
      commentsCount: 12,
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

  /// Stream reactivo de mascotas
  Stream<List<Pet>> streamPets({YagoPetStatus? status}) {
    if (!isFirebaseReady || _petsRef == null) {
      if (status == null) return Stream.value(List.from(existingPets));
      return Stream.value(existingPets.where((p) => p.status == status).toList());
    }

    Query<Map<String, dynamic>> query = _petsRef!.orderBy('date', descending: true);
    if (status != null) {
      query = _petsRef!
          .where('status', isEqualTo: status.name)
          .orderBy('date', descending: true);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    });
  }

  /// Obtiene la lista puntual de mascotas
  Future<List<Pet>> getPets({YagoPetStatus? status}) async {
    if (!isFirebaseReady || _petsRef == null) {
      if (status == null) return List.from(existingPets);
      return existingPets.where((p) => p.status == status).toList();
    }

    try {
      Query<Map<String, dynamic>> query = _petsRef!;
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
      }
    } catch (_) {}

    // Fallback a existentes si la base no responde
    if (status == null) return List.from(existingPets);
    return existingPets.where((p) => p.status == status).toList();
  }

  /// Stream reactivo de publicaciones comunitarias
  Stream<List<FeedPost>> streamFeedPosts() {
    if (!isFirebaseReady || _postsRef == null) {
      return Stream.value(List.from(existingCommunityPosts));
    }

    return _postsRef!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeedPost.fromFirestore(doc)).toList();
    });
  }

  /// Obtiene la lista puntual de publicaciones comunitarias
  Future<List<FeedPost>> getFeedPosts() async {
    if (!isFirebaseReady || _postsRef == null) {
      return List.from(existingCommunityPosts);
    }

    try {
      final snapshot = await _postsRef!.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => FeedPost.fromFirestore(doc)).toList();
      }
    } catch (_) {}
    return List.from(existingCommunityPosts);
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

  /// Alterna 'me gusta' en una publicación comunitaria
  Future<void> togglePostLike(String postId, bool newIsLiked) async {
    if (!isFirebaseReady || _postsRef == null) return;
    try {
      await _postsRef!.doc(postId).update({
        'likesCount': FieldValue.increment(newIsLiked ? 1 : -1),
        'isLiked': newIsLiked,
      });
    } catch (_) {}
  }
}
