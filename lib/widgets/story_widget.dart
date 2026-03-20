
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story_model.dart';
import '../providers/feed_provider.dart';
import 'shimmer_post.dart';
import 'cached_avatar.dart';

class StoriesTray extends StatelessWidget {
  const StoriesTray({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedNotifier>();

    if (feed.isStoriesLoading && feed.stories.isEmpty) {
      return const ShimmerStories();
    }
    if (feed.stories.isEmpty) {
      return const SizedBox.shrink();
    }

    final stories = feed.stories;

    return Container(
      height: 110, // updated tray height
      color: Colors.black,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14), // spacing
        itemBuilder: (context, index) {
          return _StoryItem(story: stories[index]);
        },
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final StoryModel story;
  const _StoryItem({required this.story});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, // fixed width to achieve ~2.5 stories
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          story.isOwn ? _buildOwnStory() : _buildStoryRing(),
          const SizedBox(height: 6),
          Text(
            story.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnStory() {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        children: [
          CachedAvatar(url: story.profileImageUrl, radius: 38),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF0095F6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryRing() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: story.isSeen
            ? null
            : const LinearGradient(
          colors: [
            Color(0xFFF58529),
            Color(0xFFDD2A7B),
            Color(0xFF8134AF),
            Color(0xFF515BD4),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        color: story.isSeen ? Colors.grey[700] : null,
      ),
      padding: const EdgeInsets.all(3), // ring thickness
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: CachedAvatar(url: story.profileImageUrl, radius: 32),
      ),
    );
  }
}
