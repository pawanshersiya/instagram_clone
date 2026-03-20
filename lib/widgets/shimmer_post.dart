// lib/widgets/shimmer_post.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPost extends StatelessWidget {
  const ShimmerPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.white),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 12),
                    const SizedBox(height: 4),
                    _box(80, 10),
                  ],
                ),
              ],
            ),
          ),
          // Image placeholder
          Container(
            width: double.infinity,
            height: 380,
            color: Colors.white,
          ),
          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _box(28, 28),
                const SizedBox(width: 16),
                _box(28, 28),
                const SizedBox(width: 16),
                _box(28, 28),
                const Spacer(),
                _box(28, 28),
              ],
            ),
          ),
          // Likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _box(100, 12),
          ),
          const SizedBox(height: 6),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _box(double.infinity, 12),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _box(200, 12),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _box(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Shimmer for stories tray
class ShimmerStories extends StatelessWidget {
  const ShimmerStories({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 7,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
