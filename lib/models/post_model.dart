// lib/models/post_model.dart

class UserModel {
  final String id;
  final String username;
  final String profileImageUrl;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    this.isVerified = false,
  });
}

class PostModel {
  final String id;
  final UserModel user;
  final List<String> imageUrls; // multiple = carousel
  final String caption;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  final String? location;

  const PostModel({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    this.location,
  });

  PostModel copyWith({
    String? id,
    UserModel? user,
    List<String>? imageUrls,
    String? caption,
    int? likeCount,
    int? commentCount,
    String? timeAgo,
    String? location,
  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
    );
  }
}
