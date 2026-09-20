import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const FeedPost({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timeAgo': timeAgo,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
    };
  }

  factory FeedPost.fromMap(Map<String, dynamic> map, String docId) {
    return FeedPost(
      id: map['id'] ?? docId,
      authorName: map['authorName'] ?? 'Comunidad Yago',
      authorAvatar: map['authorAvatar'] as String?,
      timeAgo: map['timeAgo'] ?? 'Reciente',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] as String?,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: map['isLiked'] as bool? ?? false,
    );
  }

  factory FeedPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeedPost.fromMap(data, doc.id);
  }

  FeedPost copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? timeAgo,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return FeedPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

