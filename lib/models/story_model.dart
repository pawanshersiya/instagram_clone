// lib/models/story_model.dart

class StoryModel {
  final String id;
  final String username;
  final String profileImageUrl;
  final bool isOwn;   // "Your Story"
  final bool isSeen;

  const StoryModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    this.isOwn = false,
    this.isSeen = false,
  });
}
