import 'package:cloud_firestore/cloud_firestore.dart';
import 'pet.dart';

/// Contexto resumido de un animal o publicación vinculado a un chat o mensaje (HU-S4-04).
class ChatTopicContext {
  final bool isPostContext;
  final String itemId;
  final String title;
  final String imageUrl;
  final YagoPetStatus petStatus;
  final String petBreed;
  final String petLocation;
  final String? postCategory;
  final String? postSnippet;
  final int? aiSimilarityPercentage;
  final DateTime updatedAt;

  const ChatTopicContext({
    this.isPostContext = false,
    required this.itemId,
    required this.title,
    this.imageUrl = '',
    this.petStatus = YagoPetStatus.lost,
    this.petBreed = '',
    this.petLocation = '',
    this.postCategory,
    this.postSnippet,
    this.aiSimilarityPercentage,
    required this.updatedAt,
  });

  ChatTopicContext copyWith({
    bool? isPostContext,
    String? itemId,
    String? title,
    String? imageUrl,
    YagoPetStatus? petStatus,
    String? petBreed,
    String? petLocation,
    String? postCategory,
    String? postSnippet,
    int? aiSimilarityPercentage,
    DateTime? updatedAt,
  }) {
    return ChatTopicContext(
      isPostContext: isPostContext ?? this.isPostContext,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      petStatus: petStatus ?? this.petStatus,
      petBreed: petBreed ?? this.petBreed,
      petLocation: petLocation ?? this.petLocation,
      postCategory: postCategory ?? this.postCategory,
      postSnippet: postSnippet ?? this.postSnippet,
      aiSimilarityPercentage:
          aiSimilarityPercentage ?? this.aiSimilarityPercentage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPostContext': isPostContext,
      'itemId': itemId,
      'title': title,
      'imageUrl': imageUrl,
      'petStatus': petStatus.name,
      'petBreed': petBreed,
      'petLocation': petLocation,
      'postCategory': postCategory,
      'postSnippet': postSnippet,
      'aiSimilarityPercentage': aiSimilarityPercentage,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ChatTopicContext.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    if (map['updatedAt'] is Timestamp) {
      parsedDate = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is String) {
      parsedDate =
          DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now();
    }

    return ChatTopicContext(
      isPostContext: map['isPostContext'] as bool? ?? false,
      itemId: map['itemId'] as String? ?? '',
      title: map['title'] as String? ?? 'Mascota',
      imageUrl: map['imageUrl'] as String? ?? '',
      petStatus: Pet.parseStatus(map['petStatus'] as String?),
      petBreed: map['petBreed'] as String? ?? '',
      petLocation: map['petLocation'] as String? ?? '',
      postCategory: map['postCategory'] as String?,
      postSnippet: map['postSnippet'] as String?,
      aiSimilarityPercentage: (map['aiSimilarityPercentage'] as num?)?.toInt(),
      updatedAt: parsedDate,
    );
  }
}

/// Mensaje individual dentro de una conversación de chat directo 1 a 1 (HU-S3-05, HU-S4-03, HU-S4-05).
class DirectChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime sentAt;
  final String? contextItemId;
  final String? contextTitle;
  final String? contextImage;
  final YagoPetStatus? contextPetStatus;
  final bool contextIsPost;
  final String? contextPostCategory;
  final int? contextAiSimilarity;

  const DirectChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.sentAt,
    this.contextItemId,
    this.contextTitle,
    this.contextImage,
    this.contextPetStatus,
    this.contextIsPost = false,
    this.contextPostCategory,
    this.contextAiSimilarity,
  });

  DirectChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    String? imageUrl,
    bool? isRead,
    DateTime? sentAt,
    String? contextItemId,
    String? contextTitle,
    String? contextImage,
    YagoPetStatus? contextPetStatus,
    bool? contextIsPost,
    String? contextPostCategory,
    int? contextAiSimilarity,
  }) {
    return DirectChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      contextItemId: contextItemId ?? this.contextItemId,
      contextTitle: contextTitle ?? this.contextTitle,
      contextImage: contextImage ?? this.contextImage,
      contextPetStatus: contextPetStatus ?? this.contextPetStatus,
      contextIsPost: contextIsPost ?? this.contextIsPost,
      contextPostCategory: contextPostCategory ?? this.contextPostCategory,
      contextAiSimilarity: contextAiSimilarity ?? this.contextAiSimilarity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'sentAt': Timestamp.fromDate(sentAt),
      if (contextItemId != null) 'contextItemId': contextItemId,
      if (contextTitle != null) 'contextTitle': contextTitle,
      if (contextImage != null) 'contextImage': contextImage,
      if (contextPetStatus != null) 'contextPetStatus': contextPetStatus!.name,
      'contextIsPost': contextIsPost,
      if (contextPostCategory != null)
        'contextPostCategory': contextPostCategory,
      if (contextAiSimilarity != null)
        'contextAiSimilarity': contextAiSimilarity,
    };
  }

  factory DirectChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['sentAt'] is Timestamp) {
      parsedDate = (map['sentAt'] as Timestamp).toDate();
    } else if (map['sentAt'] is String) {
      parsedDate = DateTime.tryParse(map['sentAt'] as String) ?? DateTime.now();
    }

    return DirectChatMessage(
      id: map['id'] as String? ?? docId,
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Usuario',
      text: map['text'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      sentAt: parsedDate,
      contextItemId: map['contextItemId'] as String?,
      contextTitle: map['contextTitle'] as String?,
      contextImage: map['contextImage'] as String?,
      contextPetStatus: map['contextPetStatus'] != null
          ? Pet.parseStatus(map['contextPetStatus'] as String?)
          : null,
      contextIsPost: map['contextIsPost'] as bool? ?? false,
      contextPostCategory: map['contextPostCategory'] as String?,
      contextAiSimilarity: (map['contextAiSimilarity'] as num?)?.toInt(),
    );
  }
}

/// Conversación de chat directo 1 a 1 vinculada a un reporte de mascota
/// o publicación comunitaria (HU-S3-05, HU-S4-01 a HU-S4-05).
class DirectChatConversation {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final Map<String, Map<String, dynamic>> participantDetails;
  final String contactName;
  final String contactPhone;
  final String? contactAvatar;
  final String relatedPetId;
  final String relatedPetName;
  final String relatedPetImage;
  final YagoPetStatus relatedPetStatus;
  final String relatedPetBreed;
  final String relatedPetLocation;
  final String? relatedPostId;
  final String? relatedPostCategory;
  final String? relatedPostSnippet;
  final int? aiSimilarityPercentage;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageAt;
  final int unreadCount;
  final Map<String, int> unreadCountByUser;
  final List<String> archivedByUsers;
  final List<String> deletedByUsers;
  final List<String> blockedByUsers;
  final Map<String, DateTime> clearedAtByUser;
  final List<ChatTopicContext> contexts;
  final List<DirectChatMessage> messages;

  const DirectChatConversation({
    required this.id,
    required this.participantIds,
    this.participantNames = const [],
    this.participantDetails = const {},
    required this.contactName,
    required this.contactPhone,
    this.contactAvatar,
    required this.relatedPetId,
    required this.relatedPetName,
    required this.relatedPetImage,
    required this.relatedPetStatus,
    this.relatedPetBreed = '',
    this.relatedPetLocation = '',
    this.relatedPostId,
    this.relatedPostCategory,
    this.relatedPostSnippet,
    this.aiSimilarityPercentage,
    required this.lastMessage,
    this.lastMessageSenderId = '',
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.unreadCountByUser = const {},
    this.archivedByUsers = const [],
    this.deletedByUsers = const [],
    this.blockedByUsers = const [],
    this.clearedAtByUser = const {},
    this.contexts = const [],
    this.messages = const [],
  });

  /// Indica si la conversación se originó desde una publicación comunitaria (FeedPost).
  bool get isPostContext =>
      relatedPostId != null && relatedPostId!.trim().isNotEmpty;

  /// Indica si existen mensajes no leídos en esta conversación.
  bool get hasUnread => unreadCount > 0;

  /// Indica si el usuario actual archivó esta conversación.
  bool isArchivedFor(String? userId) =>
      userId != null && archivedByUsers.contains(userId);

  /// Indica si el usuario actual eliminó esta conversación de su vista.
  bool isDeletedFor(String? userId) =>
      userId != null && deletedByUsers.contains(userId);

  /// Indica si el usuario actual bloqueó esta conversación/persona.
  bool isBlockedFor(String? userId) =>
      userId != null && blockedByUsers.contains(userId);

  /// Indica si la conversación está bloqueada por alguno de sus participantes.
  bool get isBlocked => blockedByUsers.isNotEmpty;

  /// Lista de contextos (animales o publicaciones) vinculados a esta conversación,
  /// incluyendo siempre el contexto activo principal.
  List<ChatTopicContext> get effectiveContexts {
    final currentActiveId = isPostContext
        ? (relatedPostId ?? relatedPetId)
        : relatedPetId;
    final currentContext = ChatTopicContext(
      isPostContext: isPostContext,
      itemId: currentActiveId,
      title: isPostContext
          ? (relatedPostCategory ?? 'Comunidad')
          : relatedPetName,
      imageUrl: relatedPetImage,
      petStatus: relatedPetStatus,
      petBreed: relatedPetBreed,
      petLocation: relatedPetLocation,
      postCategory: relatedPostCategory,
      postSnippet: relatedPostSnippet,
      aiSimilarityPercentage: aiSimilarityPercentage,
      updatedAt: lastMessageAt,
    );

    if (contexts.isEmpty) {
      return currentActiveId.isNotEmpty ? [currentContext] : const [];
    }

    final mapById = <String, ChatTopicContext>{};
    for (final ctx in contexts) {
      if (ctx.itemId.isNotEmpty) {
        mapById[ctx.itemId] = ctx;
      }
    }
    if (currentActiveId.isNotEmpty) {
      mapById[currentActiveId] = currentContext;
    }

    final list = mapById.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Indica si la conversación es consigo mismo (ambos participantes son el mismo usuario).
  bool isSelfChatFor(String? userId, {String? userName}) {
    if (userId != null && userId.isNotEmpty && userId != 'local-user') {
      if (participantIds.isNotEmpty &&
          participantIds.every((id) => id == userId)) {
        return true;
      }
    }
    return false;
  }

  /// Obtiene la cantidad de mensajes sin leer para un usuario específico.
  int unreadCountFor(String? userId) {
    if (userId != null && unreadCountByUser.containsKey(userId)) {
      return unreadCountByUser[userId] ?? 0;
    }
    return unreadCount;
  }

  /// Devuelve el nombre de la contraparte según quién esté viendo la conversación.
  String displayContactNameFor(
    String? currentUid, {
    String? currentUserName,
  }) {
    final normCurrentName = currentUserName?.trim().toLowerCase() ?? '';

    if (currentUid != null && participantDetails.isNotEmpty) {
      for (final entry in participantDetails.entries) {
        final key = entry.key;
        final name = (entry.value['displayName'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final isOtherId = key != currentUid;
        final isOtherName =
            normCurrentName.isEmpty || name.toLowerCase() != normCurrentName;
        if (isOtherId && isOtherName) {
          return name;
        }
      }
    }

    if (currentUid != null && messages.isNotEmpty) {
      for (final msg in messages.reversed) {
        final sName = msg.senderName.trim();
        if (msg.senderId != currentUid &&
            sName.isNotEmpty &&
            sName.toLowerCase() != 'tú' &&
            (normCurrentName.isEmpty ||
                sName.toLowerCase() != normCurrentName)) {
          return sName;
        }
      }
    }

    return contactName;
  }

  /// Devuelve el avatar de la contraparte según quién esté viendo la conversación.
  String? displayContactAvatarFor(
    String? currentUid, {
    String? currentUserName,
  }) {
    final normCurrentName = currentUserName?.trim().toLowerCase() ?? '';
    if (currentUid != null && participantDetails.isNotEmpty) {
      for (final entry in participantDetails.entries) {
        final key = entry.key;
        final name = (entry.value['displayName'] as String?)?.trim() ?? '';
        final photo = (entry.value['photoUrl'] as String?)?.trim();
        final isOtherId = key != currentUid;
        final isOtherName =
            normCurrentName.isEmpty || name.toLowerCase() != normCurrentName;
        if (isOtherId && isOtherName && photo != null && photo.isNotEmpty) {
          return photo;
        }
      }
    }
    return contactAvatar;
  }

  DirectChatConversation copyWith({
    String? id,
    List<String>? participantIds,
    List<String>? participantNames,
    Map<String, Map<String, dynamic>>? participantDetails,
    String? contactName,
    String? contactPhone,
    String? contactAvatar,
    String? relatedPetId,
    String? relatedPetName,
    String? relatedPetImage,
    YagoPetStatus? relatedPetStatus,
    String? relatedPetBreed,
    String? relatedPetLocation,
    String? relatedPostId,
    bool clearRelatedPostId = false,
    String? relatedPostCategory,
    bool clearRelatedPostCategory = false,
    String? relatedPostSnippet,
    bool clearRelatedPostSnippet = false,
    int? aiSimilarityPercentage,
    bool clearAiSimilarity = false,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    int? unreadCount,
    Map<String, int>? unreadCountByUser,
    List<String>? archivedByUsers,
    List<String>? deletedByUsers,
    List<String>? blockedByUsers,
    Map<String, DateTime>? clearedAtByUser,
    List<ChatTopicContext>? contexts,
    List<DirectChatMessage>? messages,
  }) {
    return DirectChatConversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantDetails: participantDetails ?? this.participantDetails,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactAvatar: contactAvatar ?? this.contactAvatar,
      relatedPetId: relatedPetId ?? this.relatedPetId,
      relatedPetName: relatedPetName ?? this.relatedPetName,
      relatedPetImage: relatedPetImage ?? this.relatedPetImage,
      relatedPetStatus: relatedPetStatus ?? this.relatedPetStatus,
      relatedPetBreed: relatedPetBreed ?? this.relatedPetBreed,
      relatedPetLocation: relatedPetLocation ?? this.relatedPetLocation,
      relatedPostId:
          clearRelatedPostId ? null : (relatedPostId ?? this.relatedPostId),
      relatedPostCategory: clearRelatedPostCategory
          ? null
          : (relatedPostCategory ?? this.relatedPostCategory),
      relatedPostSnippet: clearRelatedPostSnippet
          ? null
          : (relatedPostSnippet ?? this.relatedPostSnippet),
      aiSimilarityPercentage: clearAiSimilarity
          ? null
          : (aiSimilarityPercentage ?? this.aiSimilarityPercentage),
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadCountByUser: unreadCountByUser ?? this.unreadCountByUser,
      archivedByUsers: archivedByUsers ?? this.archivedByUsers,
      deletedByUsers: deletedByUsers ?? this.deletedByUsers,
      blockedByUsers: blockedByUsers ?? this.blockedByUsers,
      clearedAtByUser: clearedAtByUser ?? this.clearedAtByUser,
      contexts: contexts ?? this.contexts,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    final serializedClearedAt = <String, dynamic>{};
    for (final entry in clearedAtByUser.entries) {
      serializedClearedAt[entry.key] = Timestamp.fromDate(entry.value);
    }

    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantDetails': participantDetails,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactAvatar': contactAvatar,
      'relatedPetId': relatedPetId,
      'relatedPetName': relatedPetName,
      'relatedPetImage': relatedPetImage,
      'relatedPetStatus': relatedPetStatus.name,
      'relatedPetBreed': relatedPetBreed,
      'relatedPetLocation': relatedPetLocation,
      'relatedPostId': relatedPostId,
      'relatedPostCategory': relatedPostCategory,
      'relatedPostSnippet': relatedPostSnippet,
      'aiSimilarityPercentage': aiSimilarityPercentage,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'unreadCount': unreadCountByUser,
      'unreadCountValue': unreadCount,
      'archivedByUsers': archivedByUsers,
      'deletedByUsers': deletedByUsers,
      'blockedByUsers': blockedByUsers,
      'clearedAtByUser': serializedClearedAt,
      'contexts': contexts.map((c) => c.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DirectChatConversation.fromMap(
    Map<String, dynamic> map,
    String docId, {
    List<DirectChatMessage> messages = const [],
    String? currentUserId,
    String? currentUserName,
  }) {
    DateTime parsedDate = DateTime.now();
    if (map['lastMessageAt'] is Timestamp) {
      parsedDate = (map['lastMessageAt'] as Timestamp).toDate();
    } else if (map['lastMessageAt'] is String) {
      parsedDate =
          DateTime.tryParse(map['lastMessageAt'] as String) ?? DateTime.now();
    }

    final senderId = map['lastMessageSenderId'] as String? ?? '';
    int parsedUnread = (map['unreadCountValue'] as num?)?.toInt() ?? 0;
    final Map<String, int> parsedUnreadMap = {};
    if (map['unreadCount'] is num) {
      parsedUnread = (map['unreadCount'] as num).toInt();
    } else if (map['unreadCount'] is Map) {
      final rawMap = map['unreadCount'] as Map;
      for (final entry in rawMap.entries) {
        if (entry.value is num) {
          parsedUnreadMap[entry.key.toString()] = (entry.value as num).toInt();
        }
      }
      if (currentUserId != null) {
        if (parsedUnreadMap.containsKey(currentUserId)) {
          parsedUnread = parsedUnreadMap[currentUserId]!;
        } else if (senderId == currentUserId) {
          parsedUnread = 0;
        } else {
          // Si el reporte no tenía ownerId al momento de crearse y usó clave placeholder ('owner_...' o 'author_...'),
          // asignamos ese contador al destinatario cuando inicia sesión.
          int placeholderUnread = 0;
          for (final entry in parsedUnreadMap.entries) {
            if (entry.key != senderId &&
                (entry.key.startsWith('owner_') ||
                    entry.key.startsWith('author_') ||
                    entry.key.startsWith('contact_'))) {
              placeholderUnread += entry.value;
            }
          }
          parsedUnread = placeholderUnread;
        }
      } else if (parsedUnread == 0 && parsedUnreadMap.isNotEmpty) {
        parsedUnread = parsedUnreadMap.values.fold(0, (a, b) => a + b);
      }
    }

    if (currentUserId != null && senderId == currentUserId) {
      parsedUnread = 0;
    }

    final Map<String, Map<String, dynamic>> parsedDetails = {};
    if (map['participantDetails'] is Map) {
      final rawDetails = map['participantDetails'] as Map;
      for (final entry in rawDetails.entries) {
        if (entry.value is Map) {
          parsedDetails[entry.key.toString()] =
              Map<String, dynamic>.from(entry.value as Map);
        }
      }
    }

    final Map<String, DateTime> parsedClearedAt = {};
    if (map['clearedAtByUser'] is Map) {
      final rawCleared = map['clearedAtByUser'] as Map;
      for (final entry in rawCleared.entries) {
        final val = entry.value;
        if (val is Timestamp) {
          parsedClearedAt[entry.key.toString()] = val.toDate();
        } else if (val is String) {
          final dt = DateTime.tryParse(val);
          if (dt != null) parsedClearedAt[entry.key.toString()] = dt;
        }
      }
    }

    // Filtrar mensajes si el usuario actual vació el chat para sí mismo
    List<DirectChatMessage> effectiveMessages = messages;
    String effectiveLastMessage = map['lastMessage'] as String? ?? '';
    if (currentUserId != null && parsedClearedAt.containsKey(currentUserId)) {
      final clearedAt = parsedClearedAt[currentUserId]!;
      effectiveMessages = messages
          .where((m) => m.sentAt.isAfter(clearedAt))
          .toList();
      if (effectiveMessages.isEmpty && !parsedDate.isAfter(clearedAt)) {
        effectiveLastMessage = 'Chat vacío';
        parsedUnread = 0;
      }
    }

    final List<ChatTopicContext> parsedContexts = [];
    if (map['contexts'] is List) {
      for (final item in map['contexts'] as List) {
        if (item is Map) {
          parsedContexts.add(
            ChatTopicContext.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final baseConversation = DirectChatConversation(
      id: map['id'] as String? ?? docId,
      participantIds: List<String>.from(map['participantIds'] ?? const []),
      participantNames: List<String>.from(map['participantNames'] ?? const []),
      participantDetails: parsedDetails,
      contactName: map['contactName'] as String? ?? 'Contacto',
      contactPhone: map['contactPhone'] as String? ?? '',
      contactAvatar: map['contactAvatar'] as String?,
      relatedPetId: map['relatedPetId'] as String? ?? '',
      relatedPetName: map['relatedPetName'] as String? ?? 'Mascota',
      relatedPetImage: map['relatedPetImage'] as String? ?? '',
      relatedPetStatus: Pet.parseStatus(map['relatedPetStatus'] as String?),
      relatedPetBreed: map['relatedPetBreed'] as String? ?? '',
      relatedPetLocation: map['relatedPetLocation'] as String? ?? '',
      relatedPostId: map['relatedPostId'] as String?,
      relatedPostCategory: map['relatedPostCategory'] as String?,
      relatedPostSnippet: map['relatedPostSnippet'] as String?,
      aiSimilarityPercentage: (map['aiSimilarityPercentage'] as num?)?.toInt(),
      lastMessage: effectiveLastMessage,
      lastMessageSenderId: senderId,
      lastMessageAt: parsedDate,
      unreadCount: parsedUnread,
      unreadCountByUser: parsedUnreadMap,
      archivedByUsers: List<String>.from(map['archivedByUsers'] ?? const []),
      deletedByUsers: List<String>.from(map['deletedByUsers'] ?? const []),
      blockedByUsers: List<String>.from(map['blockedByUsers'] ?? const []),
      clearedAtByUser: parsedClearedAt,
      contexts: parsedContexts,
      messages: effectiveMessages,
    );

    if (currentUserId != null) {
      final resolvedName = baseConversation.displayContactNameFor(
        currentUserId,
        currentUserName: currentUserName,
      );
      final resolvedAvatar = baseConversation.displayContactAvatarFor(
        currentUserId,
        currentUserName: currentUserName,
      );
      return baseConversation.copyWith(
        contactName: resolvedName,
        contactAvatar: resolvedAvatar,
      );
    }

    return baseConversation;
  }
}
