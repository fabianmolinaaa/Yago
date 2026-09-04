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
