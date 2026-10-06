import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  final String id;
  final String? authorId;
  final String authorName;
  final String? authorAvatar;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
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
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isModerated = false,
    this.postType = 'general',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timeAgo': timeAgo,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
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

    return FeedPost(
      id: map['id'] ?? docId,
      authorId: map['authorId'] as String?,
      authorName: map['authorName'] ?? 'Comunidad Yago',
      authorAvatar: map['authorAvatar'] as String?,
      timeAgo: map['timeAgo'] ?? 'Reciente',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: map['isLiked'] as bool? ?? false,
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
    int? commentsCount,
    bool? isLiked,
    bool? isModerated,
    String? postType,
    DateTime? createdAt,
  }) {
    return FeedPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isModerated: isModerated ?? this.isModerated,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
