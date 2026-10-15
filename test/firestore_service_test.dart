import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/models/feed_post.dart';
import 'package:yago/models/pet.dart';
import 'package:yago/models/user_model.dart';
import 'package:yago/services/firestore_service.dart';
import 'package:yago/services/mock_data_service.dart';
import 'package:yago/utils/time_utils.dart';

void main() {
  group('Firestore Models Serialization', () {
    test('Pet toMap and fromMap serialization maintains integrity', () {
      final now = DateTime(2026, 9, 20, 12, 0);
      final pet = Pet(
        id: 'test-pet-1',
        name: 'Luna',
        breed: 'Caniche',
        species: 'Perro',
        gender: 'Hembra',
        age: '3 años',
        status: YagoPetStatus.lost,
        location: 'Palermo, CABA',
        timeAgo: 'Hace 2 horas',
        date: now,
        description: 'Lleva un moño rosa en la cabeza.',
        imageUrl: 'assets/images/IMG_3508.JPG',
        tags: const ['Moño rosa', 'Con chip'],
        contactName: 'Camila Rodriguez',
        contactPhone: '+54 9 11 4567-8901',
        latitude: -34.5889,
        longitude: -58.4233,
        isUserOwner: true,
        storyText: null,
      );

      final map = pet.toMap();
      expect(map['id'], 'test-pet-1');
      expect(map['name'], 'Luna');
      expect(map['status'], 'lost');
      expect(map['date'], isA<Timestamp>());
      expect(map['isModerated'], false);
      expect(map['isResolved'], false);

      final reconstructed = Pet.fromMap(map, 'test-pet-1');
      expect(reconstructed.id, pet.id);
      expect(reconstructed.name, pet.name);
      expect(reconstructed.breed, pet.breed);
      expect(reconstructed.species, pet.species);
      expect(reconstructed.gender, pet.gender);
      expect(reconstructed.status, pet.status);
      expect(reconstructed.location, pet.location);
      expect(reconstructed.description, pet.description);
      expect(reconstructed.imageUrl, pet.imageUrl);
      expect(reconstructed.tags, pet.tags);
      expect(reconstructed.contactName, pet.contactName);
      expect(reconstructed.isUserOwner, true);
      expect(reconstructed.isModerated, false);
      expect(reconstructed.isResolved, false);
    });

    test('FeedPost toMap and fromMap serialization maintains integrity', () {
      const post = FeedPost(
        id: 'test-post-1',
        authorName: 'Veterinaria San Roque',
        authorAvatar: 'https://example.com/avatar.jpg',
        timeAgo: 'Hace 3 horas',
        content: 'Consejo de seguridad veterinario...',
        imageUrl: 'https://example.com/image.jpg',
        likesCount: 15,
        commentsCount: 3,
        isLiked: true,
      );

      final map = post.toMap();
      expect(map['id'], 'test-post-1');
      expect(map['authorName'], 'Veterinaria San Roque');
      expect(map['likesCount'], 15);
      expect(map['isLiked'], true);
      expect(map['isModerated'], false);
      expect(map['postType'], 'general');

      final reconstructed = FeedPost.fromMap(map, 'test-post-1');
      expect(reconstructed.id, post.id);
      expect(reconstructed.authorName, post.authorName);
      expect(reconstructed.authorAvatar, post.authorAvatar);
      expect(reconstructed.content, post.content);
      expect(reconstructed.imageUrl, post.imageUrl);
      expect(reconstructed.likesCount, 15);
      expect(reconstructed.commentsCount, 3);
      expect(reconstructed.isLiked, true);
      expect(reconstructed.isModerated, false);
      expect(reconstructed.postType, 'general');
    });

    test('UserModel toMap and fromMap serialization maintains integrity', () {
      final now = DateTime(2026, 9, 20, 10, 30);
      final user = UserModel(
        uid: 'user-123',
        email: 'juan@correo.com',
        displayName: 'Juan Pérez',
        photoUrl: 'https://example.com/avatar.jpg',
        phoneNumber: '+54 9 11 1234-5678',
        bio: 'Voluntario y amante de los perros',
        location: 'Palermo, CABA',
        role: 'user',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = user.toMap();
      expect(map['uid'], 'user-123');
      expect(map['email'], 'juan@correo.com');
      expect(map['displayName'], 'Juan Pérez');
      expect(map['phoneNumber'], '+54 9 11 1234-5678');
      expect(map['bio'], 'Voluntario y amante de los perros');
      expect(map['location'], 'Palermo, CABA');
      expect(map['role'], 'user');
      expect(map['isActive'], true);
      expect(map['createdAt'], isA<Timestamp>());

      final reconstructed = UserModel.fromMap(map, 'user-123');
      expect(reconstructed.uid, 'user-123');
      expect(reconstructed.email, 'juan@correo.com');
      expect(reconstructed.displayName, 'Juan Pérez');
      expect(reconstructed.phoneNumber, '+54 9 11 1234-5678');
      expect(reconstructed.bio, 'Voluntario y amante de los perros');
      expect(reconstructed.location, 'Palermo, CABA');
      expect(reconstructed.role, 'user');
      expect(reconstructed.isActive, true);
      expect(reconstructed.createdAt, now);
    });

    test('Pet and FeedPost preserve authorId and ownerId', () {
      final pet = Pet(
        id: 'pet-owner-test',
        ownerId: 'my-user-id',
        name: 'Tobby',
        breed: 'Beagle',
        species: 'Perro',
        gender: 'Macho',
        age: '2 años',
        status: YagoPetStatus.lost,
        location: 'Belgrano',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Perrito perdido',
        imageUrl: '',
        contactName: 'Carlos',
        contactPhone: '1234',
        latitude: -34.5,
        longitude: -58.4,
      );

      expect(pet.toMap()['ownerId'], 'my-user-id');
      final reconstructedPet = Pet.fromMap(pet.toMap(), pet.id);
      expect(reconstructedPet.ownerId, 'my-user-id');

      const post = FeedPost(
        id: 'post-author-test',
        authorId: 'author-uid-456',
        authorName: 'Ana',
        timeAgo: 'Reciente',
        content: 'Hola comunidad',
      );

      expect(post.toMap()['authorId'], 'author-uid-456');
      final reconstructedPost = FeedPost.fromMap(post.toMap(), post.id);
      expect(reconstructedPost.authorId, 'author-uid-456');
    });
  });

  group('Firestore Existing Data Catalog', () {
    test('contains exact 7 existing pets without alterations', () {
      final pets = FirestoreService().existingPets;
      expect(pets.length, 7);

      final ids = pets.map((p) => p.id).toList();
      expect(ids, containsAll([
        'pet-1',
        'pet-2',
        'pet-mating-1',
        'pet-3',
        'pet-6',
        'pet-4',
        'pet-5',
      ]));

      // Verificar que Rocky conserve sus datos tal cual
      final rocky = pets.firstWhere((p) => p.id == 'pet-2');
      expect(rocky.name, 'Rocky');
      expect(rocky.status, YagoPetStatus.community);
      expect(rocky.description, 'Paseando un rato...');
      expect(rocky.location, 'Costanera, Caleta Olivia');

      // Verificar Luna perdida
      final luna = pets.firstWhere((p) => p.id == 'pet-1');
      expect(luna.name, 'Luna');
      expect(luna.status, YagoPetStatus.lost);
      expect(luna.tags, contains('Moño rosa'));

      // Verificar Simba cruza
      final simba = pets.firstWhere((p) => p.id == 'pet-mating-1');
      expect(simba.name, 'Simba');
      expect(simba.status, YagoPetStatus.mating);
    });

    test('contains exact 2 existing community posts without alterations', () {
      final posts = FirestoreService().existingCommunityPosts;
      expect(posts.length, 2);

      final authors = posts.map((p) => p.authorName).toList();
      expect(authors, containsAll([
        'Veterinaria San Roque',
        'Refugio Patitas Solidarias',
      ]));
    });

    test('MockDataService serves all existing pets and community posts', () {
      final mock = MockDataService();
      expect(mock.getAllPets().length, greaterThanOrEqualTo(7));
      expect(mock.getCommunityPosts().length, greaterThanOrEqualTo(2));
    });

    test('MockDataService addCommunityPost is async and notifies listeners', () async {
      final mock = MockDataService();
      bool notified = false;
      void listener() {
        notified = true;
      }

      mock.addListener(listener);

      const newPost = FeedPost(
        id: 'test-async-post',
        authorName: 'Comunidad Yago',
        content: 'Post de prueba asíncrono',
        timeAgo: 'Recién publicado',
      );

      await mock.addCommunityPost(newPost);
      expect(notified, isTrue);
      expect(mock.getCommunityPosts().any((p) => p.id == 'test-async-post'), isTrue);
      mock.removeListener(listener);
    });

    test('MockDataService addPet is async and notifies listeners', () async {
      final mock = MockDataService();
      bool notified = false;
      void listener() {
        notified = true;
      }

      mock.addListener(listener);

      final newPet = Pet(
        id: 'test-async-pet',
        name: 'Firulais',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: 'Adulto',
        status: YagoPetStatus.lost,
        location: 'CABA',
        timeAgo: 'Recién publicado',
        date: DateTime.now(),
        description: 'Perdido en el parque',
        imageUrl: '',
        contactName: 'Carlos',
        contactPhone: '12345',
        latitude: -34.6,
        longitude: -58.4,
      );

      await mock.addPet(newPet);
      expect(notified, isTrue);
      expect(mock.getAllPets().any((p) => p.id == 'test-async-pet'), isTrue);
      mock.removeListener(listener);
    });

    test('MockDataService deleteCommunityPost removes post and notifies listeners', () async {
      final mock = MockDataService();
      const testPost = FeedPost(
        id: 'post-delete-test',
        authorName: 'Test Author',
        content: 'Post to delete',
        timeAgo: 'Reciente',
      );
      await mock.addCommunityPost(testPost);
      expect(mock.getCommunityPosts().any((p) => p.id == 'post-delete-test'), isTrue);

      bool notified = false;
      void listener() => notified = true;
      mock.addListener(listener);

      await mock.deleteCommunityPost('post-delete-test');
      expect(mock.getCommunityPosts().any((p) => p.id == 'post-delete-test'), isFalse);
      expect(notified, isTrue);
      mock.removeListener(listener);
    });

    test('MockDataService deletePet removes pet and notifies listeners', () async {
      final mock = MockDataService();
      final testPet = Pet(
        id: 'pet-delete-test',
        name: 'Delete Me',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: 'Adulto',
        status: YagoPetStatus.lost,
        location: 'CABA',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Report to delete',
        imageUrl: '',
        contactName: 'Carlos',
        contactPhone: '123',
        latitude: -34.6,
        longitude: -58.4,
      );
      await mock.addPet(testPet);
      expect(mock.getAllPets().any((p) => p.id == 'pet-delete-test'), isTrue);

      bool notified = false;
      void listener() => notified = true;
      mock.addListener(listener);

      await mock.deletePet('pet-delete-test');
      expect(mock.getAllPets().any((p) => p.id == 'pet-delete-test'), isFalse);
      expect(notified, isTrue);
      mock.removeListener(listener);
    });

    test('MockDataService getMyPosts returns posts ordered chronologically (newest first)', () async {
      final mock = MockDataService();
      const olderPost = FeedPost(
        id: 'post-older',
        authorId: 'test-user-sort',
        authorName: 'Sort User',
        content: 'Older post',
        timeAgo: 'Ayer',
        createdAt: null,
      );
      final newerPost = FeedPost(
        id: 'post-newer',
        authorId: 'test-user-sort',
        authorName: 'Sort User',
        content: 'Newer post',
        timeAgo: 'Hoy',
        createdAt: DateTime.now(),
      );

      await mock.addCommunityPost(olderPost);
      await mock.addCommunityPost(newerPost);

      final myPosts = mock.getMyPosts(userId: 'test-user-sort');
      expect(myPosts.length, greaterThanOrEqualTo(2));
      final idxNewer = myPosts.indexWhere((p) => p.id == 'post-newer');
      final idxOlder = myPosts.indexWhere((p) => p.id == 'post-older');
      expect(idxNewer, lessThan(idxOlder));
    });
  });

  group('Time Utils', () {
    test('extractDateFromId extracts timestamp correctly', () {
      const timestamp = 1728224567890;
      final extracted = extractDateFromId('post-$timestamp');
      expect(extracted, isNotNull);
      expect(extracted!.millisecondsSinceEpoch, timestamp);
    });

    test('formatTimeAgo returns expected human readable values', () {
      final now = DateTime.now();
      expect(formatTimeAgo(now.subtract(const Duration(seconds: 10))), 'Recién publicado');
      expect(formatTimeAgo(now.subtract(const Duration(minutes: 5))), 'Hace 5 min');
      expect(formatTimeAgo(now.subtract(const Duration(hours: 3))), 'Hace 3 horas');
      expect(formatTimeAgo(now.subtract(const Duration(days: 2))), 'Hace 2 días');
      expect(formatTimeAgo(null, fallback: 'Desconocido'), 'Desconocido');
    });
  });

  group('FeedPost Category Formatting', () {
    test('categoryTag recognizes tip and removes [Consejo] in displayContent', () {
      const tipPost = FeedPost(
        id: 'post-tip-1',
        authorName: 'Dr. Lucas',
        content: '[Consejo] Evita alimentar a tu mascota con chocolate o uvas.',
        timeAgo: 'Reciente',
      );
      expect(tipPost.categoryTag, 'Consejo');
      expect(tipPost.displayContent, 'Evita alimentar a tu mascota con chocolate o uvas.');
    });

    test('categoryTag recognizes postType tip and preserves clean content', () {
      const tipPost = FeedPost(
        id: 'post-tip-2',
        authorName: 'Veterinaria San Roque',
        content: 'No dejes agua estancada para prevenir mosquitos.',
        postType: 'tip',
        timeAgo: 'Reciente',
      );
      expect(tipPost.categoryTag, 'Consejo');
      expect(tipPost.displayContent, 'No dejes agua estancada para prevenir mosquitos.');
    });

    test('categoryTag recognizes reunion story', () {
      const reunionPost = FeedPost(
        id: 'post-reunion-1',
        authorName: 'Ana',
        content: '[Reencuentro] ¡Encontramos a Toby gracias a un vecino!',
        timeAgo: 'Reciente',
      );
      expect(reunionPost.categoryTag, 'Reencuentro');
      expect(reunionPost.displayContent, '¡Encontramos a Toby gracias a un vecino!');
    });
  });

  group('Real User Likes Interaction', () {
    test('FeedPost accurately computes isLiked and likesCount based on likedBy', () {
      const post = FeedPost(
        id: 'post-likes-test',
        authorName: 'Ana',
        content: 'Post de prueba',
        timeAgo: 'Reciente',
        likedBy: ['user-alpha', 'user-beta'],
      );

      expect(post.likesCount, 2);
      expect(post.likedBy, containsAll(['user-alpha', 'user-beta']));

      final map = post.toMap();
      expect(map['likesCount'], 2);
      expect(map['likedBy'], containsAll(['user-alpha', 'user-beta']));

      final restored = FeedPost.fromMap(map, 'post-likes-test');
      expect(restored.likesCount, 2);
      expect(restored.likedBy, containsAll(['user-alpha', 'user-beta']));
    });

    test('Pet accurately computes isLiked and likesCount based on likedBy', () {
      final pet = Pet(
        id: 'pet-likes-test',
        name: 'Milo',
        breed: 'Caniche',
        species: 'Perro',
        gender: 'Macho',
        age: '1 año',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Perro perdido',
        imageUrl: '',
        contactName: 'Carlos',
        contactPhone: '1234',
        latitude: -34.5,
        longitude: -58.4,
        likedBy: ['user-gamma'],
      );

      expect(pet.likesCount, 1);
      expect(pet.likedBy, contains('user-gamma'));

      final map = pet.toMap();
      expect(map['likesCount'], 1);
      expect(map['likedBy'], contains('user-gamma'));

      final restored = Pet.fromMap(map, 'pet-likes-test');
      expect(restored.likesCount, 1);
      expect(restored.likedBy, contains('user-gamma'));
    });

    test('MockDataService togglePostLike adds and removes user from likedBy and updates count', () {
      final mock = MockDataService();
      const testPost = FeedPost(
        id: 'post-toggle-likes',
        authorName: 'María',
        content: 'Probando likes reales',
        timeAgo: 'Reciente',
        likedBy: [],
      );

      mock.addCommunityPost(testPost);
      expect(mock.getFeedPostById('post-toggle-likes')?.likesCount, 0);

      // Usuario real A da me gusta
      mock.togglePostLike('post-toggle-likes', userId: 'user-real-A');
      final postLiked = mock.getFeedPostById('post-toggle-likes');
      expect(postLiked?.likesCount, 1);
      expect(postLiked?.likedBy, contains('user-real-A'));

      // Usuario real B da me gusta
      mock.togglePostLike('post-toggle-likes', userId: 'user-real-B');
      final postLiked2 = mock.getFeedPostById('post-toggle-likes');
      expect(postLiked2?.likesCount, 2);
      expect(postLiked2?.likedBy, containsAll(['user-real-A', 'user-real-B']));

      // Usuario real A quita su me gusta
      mock.togglePostLike('post-toggle-likes', userId: 'user-real-A');
      final postUnliked = mock.getFeedPostById('post-toggle-likes');
      expect(postUnliked?.likesCount, 1);
      expect(postUnliked?.likedBy.contains('user-real-A'), isFalse);
      expect(postUnliked?.likedBy, contains('user-real-B'));
    });

    test('MockDataService togglePetLike adds and removes user from likedBy and updates count', () {
      final mock = MockDataService();
      final testPet = Pet(
        id: 'pet-toggle-likes',
        name: 'Simba',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: '2 años',
        status: YagoPetStatus.found,
        location: 'Caleta Olivia',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Encontrado en plaza',
        imageUrl: '',
        contactName: 'Lucía',
        contactPhone: '555',
        latitude: -46.4,
        longitude: -67.5,
        likedBy: [],
      );

      mock.addPet(testPet);
      expect(mock.getPetById('pet-toggle-likes')?.likesCount, 0);

      // Usuario real A da me gusta
      mock.togglePetLike('pet-toggle-likes', userId: 'user-real-A');
      final petLiked = mock.getPetById('pet-toggle-likes');
      expect(petLiked?.likesCount, 1);
      expect(petLiked?.likedBy, contains('user-real-A'));

      // Usuario real A retira me gusta
      mock.togglePetLike('pet-toggle-likes', userId: 'user-real-A');
      final petUnliked = mock.getPetById('pet-toggle-likes');
      expect(petUnliked?.likesCount, 0);
      expect(petUnliked?.likedBy.contains('user-real-A'), isFalse);
    });
  });

  group('Saved Items and Bookmarks Interaction', () {
    test('MockDataService toggleBookmark adds and removes itemId and notifies', () {
      final mock = MockDataService();
      const testId = 'test-bookmark-item';

      expect(mock.isBookmarked(testId), isFalse);

      mock.toggleBookmark(testId);
      expect(mock.isBookmarked(testId), isTrue);

      mock.toggleBookmark(testId);
      expect(mock.isBookmarked(testId), isFalse);
    });

    test('MockDataService getSavedPets and getSavedPosts filter correctly', () {
      final mock = MockDataService();

      // Guardar Luna (pet-1) y una publicación
      mock.toggleBookmark('pet-1');
      final savedPets = mock.getSavedPets();
      expect(savedPets.any((p) => p.id == 'pet-1'), isTrue);

      final posts = mock.getCommunityPosts();
      if (posts.isNotEmpty) {
        final firstPostId = posts.first.id;
        mock.toggleBookmark(firstPostId);
        final savedPosts = mock.getSavedPosts();
        expect(savedPosts.any((p) => p.id == firstPostId), isTrue);

        // Remover de guardados
        mock.toggleBookmark(firstPostId);
        expect(mock.getSavedPosts().any((p) => p.id == firstPostId), isFalse);
      }

      // Limpiar Luna
      mock.toggleBookmark('pet-1');
      expect(mock.isBookmarked('pet-1'), isFalse);
    });

    test('Pet isUserOwner checks ownerId strictly when currentUid is provided', () {
      final pet = Pet(
        id: 'pet-owner-test',
        name: 'Toby',
        breed: 'Mestizo',
        species: 'Perro',
        gender: 'Macho',
        age: '3 años',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Perro perdido',
        imageUrl: '',
        contactName: 'Carlos',
        contactPhone: '1234',
        latitude: -34.5,
        longitude: -58.4,
        isUserOwner: true,
        ownerId: 'owner-123',
      );

      // Con usuario autenticado diferente, isUserOwner debe ser falso
      expect(pet.isUserOwnerFor('other-user'), isFalse);
      // Con el dueño real autenticado, isUserOwner debe ser verdadero
      expect(pet.isUserOwnerFor('owner-123'), isTrue);
    });
  });
}

