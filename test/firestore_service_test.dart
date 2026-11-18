import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/models/ai_analysis.dart';
import 'package:yago/models/chat_conversation.dart';
import 'package:yago/models/feed_post.dart';
import 'package:yago/models/moderation_report.dart';
import 'package:yago/models/pet.dart';
import 'package:yago/models/user_model.dart';
import 'package:yago/services/ai_vision_service.dart';
import 'package:yago/services/firestore_service.dart';
import 'package:yago/services/mock_data_service.dart';
import 'package:yago/services/notification_service.dart';
import 'package:yago/utils/image_compressor.dart';
import 'package:yago/utils/input_validators.dart';
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

  group('Sprint 3: AI Vision Analysis and Database Matching', () {
    test('AiPetAnalysis serialization and combinedTags / suggestedReportDescription work accurately', () {
      final now = DateTime(2026, 10, 21, 10, 0);
      final analysis = AiPetAnalysis(
        id: 'ai-test-1',
        imageSource: 'assets/images/IMG_3508.JPG',
        species: 'Perro',
        apparentBreed: 'Caniche',
        colors: const ['Blanco', 'Rosa'],
        distinctiveTraits: const ['Moño rosa', 'Pelaje blanco'],
        confidence: 0.96,
        summary: 'Caniche blanco pequeño.',
        analyzedAt: now,
      );

      final map = analysis.toMap();
      final restored = AiPetAnalysis.fromMap(map, 'ai-test-1');
      expect(restored.id, 'ai-test-1');
      expect(restored.species, 'Perro');
      expect(restored.apparentBreed, 'Caniche');
      expect(restored.colors, containsAll(['Blanco', 'Rosa']));
      expect(restored.distinctiveTraits, contains('Moño rosa'));
      expect(restored.combinedTags, containsAll(['Blanco', 'Rosa', 'Moño rosa']));
      expect(restored.suggestedReportDescription, contains('Caniche blanco pequeño.'));
    });

    test('AiVisionService extracts physical traits and matches both lost and found pets (HU-S3-02 & HU-S3-03)', () async {
      final ai = AiVisionService();

      // 1. Analizar foto de Caniche (coincide con Luna - Perdida)
      final lostDogAnalysis = await ai.analyzeImage(
        imageUrl: 'assets/images/IMG_3508.JPG',
      );
      expect(lostDogAnalysis.species, 'Perro');
      expect(lostDogAnalysis.apparentBreed, 'Caniche');
      expect(lostDogAnalysis.colors, contains('Blanco'));
      expect(lostDogAnalysis.distinctiveTraits, contains('Moño rosa'));

      final dogMatches = ai.findMatches(lostDogAnalysis);
      expect(dogMatches, isNotEmpty);
      expect(dogMatches.first.pet.name, 'Luna');
      expect(dogMatches.first.pet.status, YagoPetStatus.lost);
      expect(dogMatches.first.similarityPercentage, greaterThanOrEqualTo(85));

      // 2. Analizar foto de Gato bicolor (coincide con Milo - Encontrada)
      final foundCatAnalysis = await ai.analyzeImage(
        imageUrl: 'assets/images/IMG_2935.JPG',
      );
      expect(foundCatAnalysis.species, 'Gato');
      expect(foundCatAnalysis.apparentBreed, contains('Gato'));

      final catMatches = ai.findMatches(foundCatAnalysis);
      expect(catMatches, isNotEmpty);
      expect(catMatches.first.pet.id, 'pet-3');
      expect(catMatches.first.pet.status, YagoPetStatus.found);
      expect(catMatches.first.similarityPercentage, greaterThanOrEqualTo(85));

      // 3. Analizar especie Otro sin coincidencias (Regla 4 y HU-S3-06)
      final rabbitAnalysis = await ai.analyzeImage(
        preset: AiVisionService.samplePresets.last,
      );
      expect(rabbitAnalysis.species, 'Otro');
      final noMatches = ai.findMatches(rabbitAnalysis);
      expect(noMatches, isEmpty);
    });

    test('MockDataService manages direct chat conversations and messages from AI matches (HU-S3-05)', () {
      final mock = MockDataService();
      final luna = mock.getPetById('pet-1')!;

      final chat = mock.getOrCreateChatForPet(luna, aiSimilarityPercentage: 96);
      expect(chat.relatedPetId, 'pet-1');
      expect(chat.contactName, 'Camila Rodriguez');
      expect(chat.aiSimilarityPercentage, 96);

      final sent = mock.sendDirectMessage(
        chat.id,
        '¡Hola Camila! Vi a Luna cerca de El Gorosito.',
      );
      expect(sent.text, '¡Hola Camila! Vi a Luna cerca de El Gorosito.');

      final updatedChat = mock.getChatById(chat.id);
      expect(updatedChat?.messages.length, 1);
      expect(updatedChat?.lastMessage, '¡Hola Camila! Vi a Luna cerca de El Gorosito.');

      // Verificar serialización de DirectChatConversation y DirectChatMessage
      final chatMap = updatedChat!.toMap();
      final restoredChat = DirectChatConversation.fromMap(chatMap, updatedChat.id);
      expect(restoredChat.id, updatedChat.id);
      expect(restoredChat.contactName, 'Camila Rodriguez');
      expect(restoredChat.aiSimilarityPercentage, 96);

      final msgMap = sent.toMap();
      final restoredMsg = DirectChatMessage.fromMap(msgMap, sent.id);
      expect(restoredMsg.id, sent.id);
      expect(restoredMsg.text, sent.text);
    });
  });

  group('Form & Input Security Validations (InputValidators)', () {
    test('validateReportDate rejects future dates and dates older than 30 days', () {
      final refNow = DateTime(2026, 10, 31, 14, 30);

      // Fechas válidas: hoy, ayer, hace 15 días y exactamente hace 30 días
      expect(
        InputValidators.validateReportDate(refNow, nowOverride: refNow),
        isNull,
      );
      expect(
        InputValidators.validateReportDate(
          refNow.subtract(const Duration(days: 1)),
          nowOverride: refNow,
        ),
        isNull,
      );
      expect(
        InputValidators.validateReportDate(
          refNow.subtract(const Duration(days: 30)),
          nowOverride: refNow,
        ),
        isNull,
      );

      // Fecha futura: mañana -> rechazada
      expect(
        InputValidators.validateReportDate(
          refNow.add(const Duration(days: 1)),
          nowOverride: refNow,
        ),
        contains('futura'),
      );

      // Fecha muy antigua (> 30 días): 31 días y 180 días atrás -> rechazada
      expect(
        InputValidators.validateReportDate(
          refNow.subtract(const Duration(days: 31)),
          nowOverride: refNow,
        ),
        contains('30 días'),
      );
      expect(
        InputValidators.validateReportDate(
          refNow.subtract(const Duration(days: 180)),
          nowOverride: refNow,
        ),
        contains('30 días'),
      );
    });

    test('validatePhone allows optional empty phone for accessibility but validates format when entered', () {
      // Opcional cuando required: false (usuarios sin línea que usan Chat Directo)
      expect(InputValidators.validatePhone('', required: false), isNull);
      expect(InputValidators.validatePhone('   ', required: false), isNull);

      // Requerido al pulsar botón "+" de agregar teléfono
      expect(InputValidators.validatePhone('', required: true), isNotNull);

      // Rechaza texto no telefónico, números cortos o ficticios repetidos
      expect(InputValidators.validatePhone('llamar por la tarde'), isNotNull);
      expect(InputValidators.validatePhone('12345'), isNotNull);
      expect(InputValidators.validatePhone('0000000000'), isNotNull);

      // Acepta formatos telefónicos reales locales e internacionales
      expect(InputValidators.validatePhone('+54 9 297 412-3456'), isNull);
      expect(InputValidators.validatePhone('2974567890'), isNull);
    });

    test('validateNeutralAge respects Rule 4 species diversity and blocks invalid values', () {
      expect(
        InputValidators.validateNeutralAge('', unknownAge: true),
        isNull,
      );
      expect(
        InputValidators.validateNeutralAge('2 años y medio', unknownAge: false),
        isNull,
      );
      expect(
        InputValidators.validateNeutralAge('Aprox. 6 meses', unknownAge: false),
        isNull,
      );

      // Rechaza valores negativos, 0 o edades irreales (> 80)
      expect(
        InputValidators.validateNeutralAge('-3 años', unknownAge: false),
        isNotNull,
      );
      expect(
        InputValidators.validateNeutralAge('0 años', unknownAge: false),
        isNotNull,
      );
      expect(
        InputValidators.validateNeutralAge('250 años', unknownAge: false),
        isNotNull,
      );
    });

    test('validatePersonName blocks reserved official names and non-letter strings', () {
      expect(InputValidators.validatePersonName(''), 'Por favor, ingresa tu nombre completo.');
      expect(InputValidators.validatePersonName('123456'), isNotNull);
      expect(InputValidators.validatePersonName('Equipo Yago'), contains('reservado'));
      expect(InputValidators.validatePersonName('Comunidad Yago'), contains('reservado'));
      expect(InputValidators.validatePersonName('Admin'), contains('reservado'));
      expect(InputValidators.validatePersonName('Camila Rodríguez'), isNull);
    });

    test('isValidEmail supports modern TLDs and rejects malformed addresses', () {
      expect(InputValidators.isValidEmail('usuario@universidad.edu.ar'), isTrue);
      expect(InputValidators.isValidEmail('vecino+yago@comunidad.digital'), isTrue);
      expect(InputValidators.isValidEmail('correo-invalido'), isFalse);
      expect(InputValidators.isValidEmail('sin-dominio@'), isFalse);
    });

    test('inferCoordinatesFromText maps known Caleta Olivia neighborhoods for manual accessibility', () {
      final miramarCoords = InputValidators.inferCoordinatesFromText('Barrio Miramar, cerca de la playa');
      expect(miramarCoords.latitude, closeTo(-46.4478, 0.001));
      expect(miramarCoords.longitude, closeTo(-67.5150, 0.001));
    });
  });

  group('ImageCompressor High-Quality Non-Aggressive Pipeline', () {
    test('presetForFolder maps avatars and post/report folders accurately', () {
      expect(
        ImageCompressor.presetForFolder('avatars'),
        equals(ImageCompressionPreset.avatar),
      );
      expect(
        ImageCompressor.presetForFolder('reports'),
        equals(ImageCompressionPreset.postAndReport),
      );
      expect(
        ImageCompressor.presetForFolder('community_posts'),
        equals(ImageCompressionPreset.postAndReport),
      );
      expect(
        ImageCompressor.presetForFolder('mating_posts'),
        equals(ImageCompressionPreset.postAndReport),
      );

      // Verificar calibración de alta fidelidad (1600 px al 85% para publicaciones/reportes)
      expect(ImageCompressionPreset.postAndReport.maxDimension, equals(1600));
      expect(ImageCompressionPreset.postAndReport.quality, equals(85));
      expect(ImageCompressionPreset.avatar.maxDimension, equals(800));
      expect(ImageCompressionPreset.avatar.quality, equals(85));
    });

    test('compressFileWithStats smart-skips small already-optimized JPEG files and handles missing files safely', () async {
      final missing = File('${Directory.systemTemp.path}/non_existent_yago_img.jpg');
      final missingStats = await ImageCompressor.compressFileWithStats(missing);
      expect(missingStats.wasCompressed, isFalse);
      expect(missingStats.originalBytes, equals(0));

      final tempJpg = File(
        '${Directory.systemTemp.path}/yago_test_small_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await tempJpg.writeAsBytes(List<int>.filled(4096, 0xFF));
      try {
        final stats = await ImageCompressor.compressFileWithStats(
          tempJpg,
          preset: ImageCompressionPreset.postAndReport,
        );
        expect(stats.wasCompressed, isFalse);
        expect(stats.file.path, equals(tempJpg.path));
        expect(stats.savedPercentage, equals(0.0));
      } finally {
        if (await tempJpg.exists()) {
          await tempJpg.delete();
        }
      }
    });
  });

  group('Sprint 4: Direct Chat Between People (HU-S4-01 to HU-S4-05)', () {
    test('getChatConversations orders active chats chronologically and updates order on new message (HU-S4-01)', () {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final luna = mock.getPetById('pet-1')!;
      final thor = mock.getPetById('pet-4')!;

      final chatLuna = mock.getOrCreateChatForPet(luna);
      final chatThor = mock.getOrCreateChatForPet(thor);

      // Enviar mensaje en chatLuna y luego un mensaje más reciente en chatThor
      mock.sendDirectMessage(chatLuna.id, 'Hola Camila, consulta por Luna');
      mock.receiveDirectMessage(
        chatThor.id,
        'Hola, Thor sigue en Barrio Gregores',
        sentAt: DateTime.now().add(const Duration(seconds: 5)),
      );

      final ordered = mock.getChatConversations();
      expect(ordered.length, 2);
      expect(ordered.first.id, equals(chatThor.id));
      expect(ordered.last.id, equals(chatLuna.id));

      // Ahora llega una nueva respuesta en chatLuna -> pasa al primer lugar cronológico
      mock.receiveDirectMessage(
        chatLuna.id,
        '¡Gracias por escribirme! ¿Por dónde la viste?',
        sentAt: DateTime.now().add(const Duration(seconds: 15)),
      );

      final reordered = mock.getChatConversations();
      expect(reordered.first.id, equals(chatLuna.id));
      expect(reordered.last.id, equals(chatThor.id));
    });

    test('getOrCreateChatForPost links community FeedPost context and serializes accurately (HU-S4-02 & HU-S4-04)', () {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final post = mock.getCommunityPosts().first.copyWith(postType: 'tip');
      final postChat = mock.getOrCreateChatForPost(post);

      expect(postChat.isPostContext, isTrue);
      expect(postChat.relatedPostId, equals(post.id));
      expect(postChat.contactName, equals(post.authorName));
      expect(postChat.relatedPostCategory, equals('Consejo'));
      expect(postChat.relatedPostSnippet, isNotEmpty);

      final map = postChat.toMap();
      final restored = DirectChatConversation.fromMap(map, postChat.id);
      expect(restored.isPostContext, isTrue);
      expect(restored.relatedPostId, equals(post.id));
      expect(restored.relatedPostCategory, equals('Consejo'));
      expect(restored.relatedPostSnippet, equals(postChat.relatedPostSnippet));
    });

    test('unread indicators increment on incoming messages, support photo attachments, and clear on markChatAsRead (HU-S4-03 & HU-S4-05)', () {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final milo = mock.getPetById('pet-3')!;
      final chat = mock.getOrCreateChatForPet(milo);
      expect(mock.getTotalUnreadChatCount(), equals(0));
      expect(mock.getUnreadConversationsCount(), equals(0));

      // Recibir 2 mensajes entrantes (uno de texto y uno con foto adjunta)
      mock.receiveDirectMessage(
        chat.id,
        'Hola, te envío una foto de cómo está Milo ahora.',
      );
      mock.receiveDirectMessage(
        chat.id,
        '',
        imageUrl: 'assets/images/IMG_2935.JPG',
      );

      expect(mock.getTotalUnreadChatCount(), equals(2));
      expect(mock.getUnreadConversationsCount(), equals(1));
      final updated = mock.getChatById(chat.id)!;
      expect(updated.unreadCount, equals(2));
      expect(updated.hasUnread, isTrue);
      expect(updated.lastMessage, equals('📷 Foto adjunta'));
      expect(updated.messages.last.imageUrl, equals('assets/images/IMG_2935.JPG'));

      // Al marcar el chat como leído, el contador vuelve a 0 y los mensajes quedan isRead: true
      mock.markChatAsRead(chat.id);
      expect(mock.getTotalUnreadChatCount(), equals(0));
      expect(mock.getUnreadConversationsCount(), equals(0));
      final afterRead = mock.getChatById(chat.id)!;
      expect(afterRead.unreadCount, equals(0));
      expect(afterRead.messages.every((m) => m.isRead), isTrue);
    });

    test('archive, clear for current user only, delete, and multi-account recipient view work accurately', () {
      final mock = MockDataService();
      mock.clearUserProfileCache();

      final luna = mock.getPetById('pet-1')!.copyWith(
        ownerId: 'uid_william',
        contactName: 'William',
      );
      final chat = mock.getOrCreateChatForPet(luna);
      final msg = mock.sendDirectMessage(
        chat.id,
        'Hola William, vi a tu mascota',
        senderName: 'Fabian',
      );

      final updated = mock.getChatById(chat.id)!;
      final serialized = updated.toMap();

      // Vista desde la cuenta del remitente ('local-user' / Fabian): 0 no leídos y contacto 'William'
      final senderView = DirectChatConversation.fromMap(
        serialized,
        chat.id,
        messages: [msg],
        currentUserId: 'local-user',
        currentUserName: 'Fabian',
      );
      expect(senderView.unreadCount, equals(0));
      expect(senderView.contactName, equals('William'));

      // Vista desde la cuenta del reportante ('uid_william' / William): 1 no leído y contacto 'Fabian'
      final recipientView = DirectChatConversation.fromMap(
        serialized,
        chat.id,
        messages: [msg],
        currentUserId: 'uid_william',
        currentUserName: 'William',
      );
      expect(recipientView.unreadCount, equals(1));
      expect(recipientView.contactName, equals('Fabian'));
      expect(recipientView.messages.length, equals(1));

      // Archivar chat lo mueve a archivados y lo oculta de la lista principal
      final archived = mock.toggleArchiveChat(chat.id);
      expect(archived, isTrue);
      expect(mock.getChatConversations().isEmpty, isTrue);
      expect(mock.getChatConversations(onlyArchived: true).length, equals(1));

      // Desarchivar chat lo devuelve a la lista principal
      final unarchived = mock.toggleArchiveChat(chat.id);
      expect(unarchived, isFalse);
      expect(mock.getChatConversations().length, equals(1));

      // Vaciar chat lo vacía únicamente para el usuario actual, conservando el mensaje para el otro participante
      mock.clearChatForUser(chat.id);
      final afterClearLocal = mock.getChatById(chat.id)!;
      expect(afterClearLocal.messages, isEmpty);
      expect(afterClearLocal.lastMessage, equals('Chat vacío'));

      final clearedMap = afterClearLocal.toMap();
      final otherUserAfterClear = DirectChatConversation.fromMap(
        clearedMap,
        chat.id,
        messages: [msg],
        currentUserId: 'uid_william',
        currentUserName: 'William',
      );
      expect(otherUserAfterClear.messages.length, equals(1));
    });
  });

  group('Sprint 5: Community Moderation Reports (HU-S5-01)', () {
    test('ModerationReport serialization maintains field integrity and timestamps', () {
      final now = DateTime(2026, 11, 10, 10, 0);
      final report = ModerationReport(
        id: 'mod-123',
        reporterId: 'usr-reporter-456',
        reporterName: 'Juan Pérez',
        reporterEmail: 'juan@example.com',
        targetType: 'pet',
        targetId: 'pet-1',
        targetTitle: 'Luna',
        targetAuthorId: 'seed-camila-rodriguez',
        targetAuthorName: 'Camila Rodriguez',
        reason: 'fake',
        reasonTitle: 'Información falsa o broma',
        description: 'La foto parece descargada de Google y no coincide con la zona.',
        status: 'pending',
        createdAt: now,
      );

      final map = report.toMap();
      expect(map['id'], equals('mod-123'));
      expect(map['reporterId'], equals('usr-reporter-456'));
      expect(map['reporterName'], equals('Juan Pérez'));
      expect(map['targetType'], equals('pet'));
      expect(map['targetId'], equals('pet-1'));
      expect(map['targetTitle'], equals('Luna'));
      expect(map['reason'], equals('fake'));
      expect(map['reasonTitle'], equals('Información falsa o broma'));
      expect(map['status'], equals('pending'));
      expect(map['createdAt'], isA<Timestamp>());

      final restored = ModerationReport.fromMap(map, id: 'mod-123');
      expect(restored.id, equals('mod-123'));
      expect(restored.reporterId, equals('usr-reporter-456'));
      expect(restored.targetType, equals('pet'));
      expect(restored.targetId, equals('pet-1'));
      expect(restored.reason, equals('fake'));
      expect(restored.description, contains('descargada de Google'));
      expect(restored.status, equals('pending'));
      expect(restored.createdAt.year, equals(2026));
    });

    test('ModerationReasonOption defaults include all pet-centric community violation types', () {
      final options = ModerationReasonOption.defaultOptions;
      expect(options.length, greaterThanOrEqualTo(6));

      final codes = options.map((o) => o.code).toSet();
      expect(codes, contains('fake'));
      expect(codes, contains('scam'));
      expect(codes, contains('spam'));
      expect(codes, contains('offensive'));
      expect(codes, contains('duplicate'));
      expect(codes, contains('other'));

      // Verifica que los textos estén adaptados a la comunidad de animales de Yago
      final titles = options.map((o) => o.title.toLowerCase()).toList();
      expect(titles.any((t) => t.contains('falsa') || t.contains('broma')), isTrue);
      expect(titles.any((t) => t.contains('estafa') || t.contains('recompensa')), isTrue);
      expect(titles.any((t) => t.contains('venta de animales') || t.contains('spam')), isTrue);
      expect(titles.any((t) => t.contains('maltrato')), isTrue);
      expect(titles.any((t) => t.contains('resuelto') || t.contains('repetido')), isTrue);
    });

    test('FirestoreService and MockDataService handle moderation reports reliably', () async {
      final mock = MockDataService();
      final initialCount = mock.moderationReports.length;

      final report = ModerationReport(
        id: 'mod-test-999',
        reporterId: 'usr-test-1',
        targetType: 'feed_post',
        targetId: 'post-test-1',
        targetTitle: 'Venta de cachorros no permitida',
        reason: 'spam',
        reasonTitle: 'Venta de animales o publicidad (Spam)',
        description: 'Está vendiendo animales con fines de lucro.',
        createdAt: DateTime.now(),
      );

      // Guardar en FirestoreService (modo mock/offline seguro)
      final firestoreResult = await FirestoreService().submitModerationReport(report);
      expect(firestoreResult, isTrue);

      // Registrar en MockDataService
      mock.addModerationReport(report);
      expect(mock.moderationReports.length, equals(initialCount + 1));
      expect(mock.moderationReports.last.id, equals('mod-test-999'));
      expect(mock.moderationReports.last.reason, equals('spam'));
    });

    test('Direct chat unifies multiple animals with the same person and preserves per-animal context', () {
      final mock = MockDataService();
      final petA = Pet(
        id: 'pet-unified-a',
        name: 'Kira',
        breed: 'Border Collie',
        species: 'Perro',
        gender: 'Hembra',
        age: '2 años',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Hace 1h',
        date: DateTime.now(),
        description: 'Perdida cerca de la costanera',
        imageUrl: '',
        contactName: 'Valeria Méndez',
        contactPhone: '2974112233',
        latitude: -46.43,
        longitude: -67.52,
        ownerId: 'uid_valeria_mendez',
      );
      final petB = Pet(
        id: 'pet-unified-b',
        name: 'Michi',
        breed: 'Siamés',
        species: 'Gato',
        gender: 'Macho',
        age: '1 año',
        status: YagoPetStatus.found,
        location: 'Barrio Miramar, Caleta Olivia',
        timeAgo: 'Hace 10m',
        date: DateTime.now(),
        description: 'Encontrado en el jardín',
        imageUrl: '',
        contactName: 'Valeria Méndez',
        contactPhone: '2974112233',
        latitude: -46.44,
        longitude: -67.51,
        ownerId: 'uid_valeria_mendez',
      );

      final chat1 = mock.getOrCreateChatForPet(petA);
      mock.sendDirectMessage(chat1.id, 'Hola Valeria, vi a Kira en la playa.');

      final chat2 = mock.getOrCreateChatForPet(petB);

      // Debe ser exactamente el mismo chat unificado con Valeria
      expect(chat2.id, equals(chat1.id));
      expect(chat2.effectiveContexts.length, equals(2));
      expect(chat2.relatedPetId, equals('pet-unified-b'));
      expect(chat2.relatedPetName, equals('Michi'));

      mock.sendDirectMessage(chat2.id, 'También te escribo por Michi.');

      final updated = mock.getChatById(chat1.id)!;
      expect(updated.messages.length, equals(2));
      expect(updated.messages[0].contextItemId, equals('pet-unified-a'));
      expect(updated.messages[0].contextTitle, equals('Kira'));
      expect(updated.messages[1].contextItemId, equals('pet-unified-b'));
      expect(updated.messages[1].contextTitle, equals('Michi'));

      // Cambiar el contexto activo de vuelta a Kira
      final kiraTopic = updated.effectiveContexts.firstWhere(
        (c) => c.itemId == 'pet-unified-a',
      );
      final switched = mock.switchActiveChatContext(updated.id, kiraTopic);
      expect(switched.relatedPetId, equals('pet-unified-a'));
      expect(switched.relatedPetName, equals('Kira'));
    });

    test('Reporting a chat removes it from inbox and blocks future messages from that person', () {
      final mock = MockDataService();
      final spammerPet = Pet(
        id: 'pet-spammer-1',
        name: 'Toto',
        breed: 'Caniche',
        species: 'Perro',
        gender: 'Macho',
        age: '3 años',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Reciente',
        date: DateTime.now(),
        description: 'Reporte sospechoso',
        imageUrl: '',
        contactName: 'Usuario Bloqueado Test',
        contactPhone: '2974999999',
        latitude: -46.43,
        longitude: -67.52,
        ownerId: 'uid_blocked_spammer',
      );

      final chat = mock.getOrCreateChatForPet(spammerPet);
      mock.sendDirectMessage(chat.id, 'Hola');
      expect(
        mock.getChatConversations().any((c) => c.id == chat.id),
        isTrue,
      );

      // Reportar el chat directo
      final report = ModerationReport(
        id: 'mod-block-chat-1',
        reporterId: 'local-user',
        targetType: 'chat_message',
        targetId: chat.id,
        targetTitle: 'Conversación con Usuario Bloqueado Test',
        targetAuthorId: 'uid_blocked_spammer',
        targetAuthorName: 'Usuario Bloqueado Test',
        reason: 'scam',
        reasonTitle: 'Estafa o extorsión con recompensa',
        createdAt: DateTime.now(),
      );
      mock.addModerationReport(report);

      // 1. El chat ya no aparece en la bandeja activa ni en archivados
      expect(
        mock.getChatConversations().any((c) => c.id == chat.id),
        isFalse,
      );
      expect(
        mock.getChatConversations(includeArchived: true).any((c) => c.id == chat.id),
        isFalse,
      );

      // 2. La persona queda bloqueada y no puede enviar más mensajes
      expect(
        mock.isPersonBlocked(
          userId: 'uid_blocked_spammer',
          userName: 'Usuario Bloqueado Test',
        ),
        isTrue,
      );
      final incomingAfterBlock = mock.receiveDirectMessage(
        chat.id,
        'Mensaje no deseado después del bloqueo',
      );
      expect(incomingAfterBlock, isNull);
    });

    test('NotificationService shows generic message notification and accumulates count on multiple incoming messages', () async {
      final mock = MockDataService();
      final notifications = NotificationService();
      mock.markAllChatsAsRead();
      await notifications.clearNotifications();

      final petNotif = Pet(
        id: 'pet-notif-test',
        name: 'Rocky',
        breed: 'Labrador',
        species: 'Perro',
        gender: 'Macho',
        age: '2 años',
        status: YagoPetStatus.lost,
        location: 'Caleta Olivia',
        timeAgo: 'Hace 5m',
        date: DateTime.now(),
        description: 'Perdido en centro',
        imageUrl: '',
        contactName: 'Lucas Fernández',
        contactPhone: '2974001122',
        latitude: -46.43,
        longitude: -67.52,
        ownerId: 'uid_lucas_fernandez_notif',
      );

      final chat = mock.getOrCreateChatForPet(petNotif);

      // 1er mensaje entrante -> "Has recibido un mensaje" (sin exponer contenido)
      mock.receiveDirectMessage(chat.id, 'Hola, tengo información secreta 1');
      expect(notifications.accumulatedMessagesCount, equals(1));
      expect(notifications.lastNotificationTitle, equals('Yago'));
      expect(notifications.lastNotificationBody, equals('Has recibido un mensaje'));

      // 2do mensaje entrante -> acumula a 2: "Has recibido 2 mensajes"
      mock.receiveDirectMessage(chat.id, 'Te mando ubicación 2');
      expect(notifications.accumulatedMessagesCount, equals(2));
      expect(notifications.lastNotificationBody, equals('Has recibido 2 mensajes'));

      // 3er mensaje entrante -> acumula a 3: "Has recibido 3 mensajes"
      mock.receiveDirectMessage(chat.id, 'Avísame cuando llegues 3');
      expect(notifications.accumulatedMessagesCount, equals(3));
      expect(notifications.lastNotificationBody, equals('Has recibido 3 mensajes'));

      // Al marcar el chat como leído, se limpia el contador acumulado y la notificación
      mock.markChatAsRead(chat.id);
      expect(notifications.accumulatedMessagesCount, equals(0));
      expect(notifications.lastNotificationBody, isNull);
    });
  });
}

