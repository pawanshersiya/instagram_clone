// lib/services/post_repository.dart

import '../models/post_model.dart';
import '../models/story_model.dart';

/// Simulates a network data layer.
/// Returns paginated posts with a 1.5-second artificial delay.
class PostRepository {
  // ── Mock Users ──────────────────────────────────────────────────────────────
  static final _users = [
    UserModel(
      id: 'u1',
      username: 'natgeo',
      profileImageUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      isVerified: true,
    ),
    UserModel(
      id: 'u2',
      username: 'nasa',
      profileImageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      isVerified: true,
    ),
    UserModel(
      id: 'u3',
      username: 'travel.diaries',
      profileImageUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
    ),
    UserModel(
      id: 'u4',
      username: 'food_lovers',
      profileImageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    ),
    UserModel(
      id: 'u5',
      username: 'architecture.now',
      profileImageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    ),
    UserModel(
      id: 'u6',
      username: 'ocean.tales',
      profileImageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    ),
  ];

  // ── Mock Post Images (high-quality Unsplash URLs) ───────────────────────────
  static const _postImages = [
    // Nature
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    // Cities
    'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800',
    'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800',
    'https://images.unsplash.com/photo-1514565131-fce0801e6f64?w=800',
    // Food
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800',
    // Architecture
    'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800',
    'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?w=800',
    'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800',
    // Ocean
    'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=800',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
    // Extra
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800',
  ];

  static const _captions = [
    '🌄 The mountains are calling and I must go. #nature #mountains #adventure',
    '✨ Lost in the beauty of the cosmos. The universe is vast and full of wonders. #space #nasa',
    '🗺️ Every journey begins with a single step. Where will yours take you? #travel #wanderlust',
    '🍕 Life is too short for bad food. Savoring every bite of this masterpiece. #foodie #delicious',
    '🏙️ Cities are like open books — every corner tells a story. #architecture #urban',
    '🌊 The ocean stirs the heart, inspires the imagination and brings eternal joy. #ocean #waves',
    '🌿 In every walk with nature, one receives far more than he seeks. #forest #peace',
    '🌅 Golden hour magic never gets old. Chasing sunsets around the world. #sunset #golden',
    '🎨 Life imitates art far more than art imitates life. #art #creative',
    '🔭 Looking up and wondering — there are more stars than grains of sand on Earth. #astronomy',
  ];

  static const _locations = [
    'Swiss Alps, Switzerland',
    'Kennedy Space Center, FL',
    'Santorini, Greece',
    'New York City, NY',
    'Tokyo, Japan',
    'Maldives',
    'Amazon Rainforest, Brazil',
    'Sahara Desert, Morocco',
    null,
    null,
  ];

  // ── Build a PostModel from index ─────────────────────────────────────────────
  PostModel _buildPost(int globalIndex) {
    final user = _users[globalIndex % _users.length];
    final imgA = _postImages[globalIndex % _postImages.length];
    final imgB = _postImages[(globalIndex + 3) % _postImages.length];
    final imgC = _postImages[(globalIndex + 6) % _postImages.length];

    // Every 3rd post is a carousel (3 images)
    final isCarousel = globalIndex % 3 == 0;
    final images = isCarousel ? [imgA, imgB, imgC] : [imgA];

    return PostModel(
      id: 'post_$globalIndex',
      user: user,
      imageUrls: images,
      caption: _captions[globalIndex % _captions.length],
      likeCount: 1000 + (globalIndex * 347) % 49000,
      commentCount: 50 + (globalIndex * 73) % 2000,
      timeAgo: _timeAgo(globalIndex),
      location: _locations[globalIndex % _locations.length],
    );
  }

  String _timeAgo(int i) {
    final options = ['2m', '15m', '1h', '3h', '6h', '12h', '1d', '2d'];
    return options[i % options.length];
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Fetches a page of posts with a simulated 1.5-second network delay.
  Future<List<PostModel>> fetchPosts({int page = 0, int pageSize = 10}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1500));

    final start = page * pageSize;
    return List.generate(pageSize, (i) => _buildPost(start + i));
  }

  /// Fetches stories with a simulated delay.
  Future<List<StoryModel>> fetchStories() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      StoryModel(
        id: 'own',
        username: 'Your Story',
        profileImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        isOwn: true,
      ),
      StoryModel(
        id: 's1',
        username: 'natgeo',
        profileImageUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      ),
      StoryModel(
        id: 's2',
        username: 'nasa',
        profileImageUrl:
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
        isSeen: true,
      ),
      StoryModel(
        id: 's3',
        username: 'travel.diaries',
        profileImageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      ),
      StoryModel(
        id: 's4',
        username: 'food_lovers',
        profileImageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        isSeen: true,
      ),
      StoryModel(
        id: 's5',
        username: 'arch.now',
        profileImageUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      ),
      StoryModel(
        id: 's6',
        username: 'ocean.tales',
        profileImageUrl:
            'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=150',
      ),
    ];
  }
}
