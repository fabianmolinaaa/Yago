import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yago/models/feed_post.dart';
import 'package:yago/models/pet.dart';
import 'package:yago/models/user_model.dart';
import 'package:yago/services/firestore_service.dart';
import 'package:yago/services/mock_data_service.dart';

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

      final reconstructed = FeedPost.fromMap(map, 'test-post-1');
      expect(reconstructed.id, post.id);
      expect(reconstructed.authorName, post.authorName);
      expect(reconstructed.authorAvatar, post.authorAvatar);
      expect(reconstructed.content, post.content);
      expect(reconstructed.imageUrl, post.imageUrl);
      expect(reconstructed.likesCount, 15);
      expect(reconstructed.commentsCount, 3);
      expect(reconstructed.isLiked, true);
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
      expect(mock.getAllPets().length, 7);
      expect(mock.getCommunityPosts().length, 2);
    });
  });
}
