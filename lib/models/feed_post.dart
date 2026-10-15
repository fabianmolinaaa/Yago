import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class FeedPost {
  final String id;
  final String? authorId;
  final String authorName;
  final String? authorAvatar;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final int _explicitLikesCount;
  final List<String> likedBy;
  final int commentsCount;
  final bool _explicitIsLiked;
  final bool isModerated;
  final String postType; // 'general', 'tip', 'success_story', etc.
  final DateTime? createdAt;

  const FeedPost({
    required this.id,
    this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    int likesCount = 0,
    this.likedBy = const [],
    this.commentsCount = 0,
    bool isLiked = false,
    this.isModerated = false,
    this.postType = 'general',
    this.createdAt,
  })  : _explicitLikesCount = likesCount,
        _explicitIsLiked = isLiked;

  int get likesCount =>
      likedBy.isNotEmpty ? likedBy.length : _explicitLikesCount;

  bool get isLiked {
    final currentUid = AuthService().currentUser?.uid;
    if (currentUid != null) {
      return likedBy.contains(currentUid);
    }
    return _explicitIsLiked;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timeAgo': timeAgo,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likedBy.isNotEmpty ? likedBy.length : likesCount,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'isModerated': isModerated,
      'postType': postType,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory FeedPost.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt'] as String);
    }

    if (parsedCreatedAt == null) {
      final idStr = (map['id'] as String?) ?? docId;
      final match = RegExp(r'\d{10,}').firstMatch(idStr);
      if (match != null) {
        final millis = int.tryParse(match.group(0)!);
        if (millis != null) {
          parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(millis);
        }
      }
    }

    final likedByList = (map['likedBy'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final rawLikesCount = (map['likesCount'] as num?)?.toInt() ?? 0;
    final actualLikesCount =
        likedByList.isNotEmpty ? likedByList.length : rawLikesCount;
    final currentUid = AuthService().currentUser?.uid;
    final isLikedCalculated = currentUid != null && likedByList.isNotEmpty
        ? likedByList.contains(currentUid)
        : (map['isLiked'] as bool? ?? false);

    return FeedPost(
      id: map['id'] ?? docId,
      authorId: map['authorId'] as String?,
      authorName: map['authorName'] ?? 'Comunidad Yago',
      authorAvatar: map['authorAvatar'] as String?,
      timeAgo: map['timeAgo'] ?? 'Reciente',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      likesCount: actualLikesCount,
      likedBy: likedByList,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: isLikedCalculated,
      isModerated: map['isModerated'] as bool? ?? false,
      postType: map['postType'] as String? ?? 'general',
      createdAt: parsedCreatedAt,
    );
  }

  factory FeedPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeedPost.fromMap(data, doc.id);
  }

  FeedPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? timeAgo,
    String? content,
    String? imageUrl,
    int? likesCount,
    List<String>? likedBy,
    int? commentsCount,
    bool? isLiked,
    bool? isModerated,
    String? postType,
    DateTime? createdAt,
  }) {
    final newLikedBy = likedBy ?? this.likedBy;
    return FeedPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? (likedBy != null ? newLikedBy.length : this.likesCount),
      likedBy: newLikedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isModerated: isModerated ?? this.isModerated,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Categoría normalizada para presentación ('Consejo', 'Reencuentro', 'Comunidad', o null).
  String? get categoryTag {
    final type = postType.toLowerCase().trim();
    if (type == 'tip' || type == 'consejo') return 'Consejo';
    if (type == 'reunion' || type == 'reencuentro') return 'Reencuentro';
    if (type == 'community' || type == 'comunidad' || type == 'aviso') return 'Comunidad';

    final text = content.trim();
    if (text.startsWith('[Consejo]') || text.startsWith('💡 Consejo')) return 'Consejo';
    if (text.startsWith('[Reencuentro]') || text.startsWith('❤️ Reencuentro')) return 'Reencuentro';
    if (text.startsWith('[Comunidad]') || text.startsWith('[Aviso]')) return 'Comunidad';

    return null;
  }

  /// Texto limpio sin prefijos crudos como '[Consejo]' o '[Reencuentro]'.
  String get displayContent {
    String text = content.trim();
    if (text.startsWith('[Consejo]')) {
      final stripped = text.substring(9).trim();
      if (stripped.isNotEmpty) return stripped;
    } else if (text.startsWith('💡 Consejo de seguridad:')) {
      final stripped = text.substring(24).trim();
      if (stripped.isNotEmpty) return stripped;
    } else if (text.startsWith('💡 Consejo:')) {
      final stripped = text.substring(11).trim();
      if (stripped.isNotEmpty) return stripped;
    } else if (text.startsWith('[Reencuentro]')) {
      final stripped = text.substring(13).trim();
      if (stripped.isNotEmpty) return stripped;
    } else if (text.startsWith('[Comunidad]')) {
      final stripped = text.substring(11).trim();
      if (stripped.isNotEmpty) return stripped;
    } else if (text.startsWith('[Aviso]')) {
      final stripped = text.substring(7).trim();
      if (stripped.isNotEmpty) return stripped;
    }
    return text;
  }
}
