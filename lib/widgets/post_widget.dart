// lib/widgets/post_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import 'cached_avatar.dart';
import 'pinch_to_zoom.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 20),
    ]).animate(_heartController);

    _pageController = PageController();
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final feed = context.read<FeedNotifier>();
    final isLiked = feed.isLiked(widget.post.id);
    if (!isLiked) {
      feed.toggleLike(widget.post.id);
    }
    _heartController.reset();
    _heartController.forward().then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
    setState(() => _showHeart = true);
  }

  void _showSnackbar(String label) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label feature not implemented yet',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF262626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedNotifier>();
    final isLiked = feed.isLiked(widget.post.id);
    final isSaved = feed.isSaved(widget.post.id);

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildImageSection(),
          _buildDotIndicatorIfCarousel(),
          _buildActionRow(isLiked, isSaved),
          _buildCaption(),
          _buildCommentPreview(),
          _buildTimestamp(),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF262626), height: 0.5),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final hasLocation = widget.post.location != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF58529),
                  Color(0xFFDD2A7B),
                  Color(0xFF8134AF),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(1.5),
              child: CachedAvatar(
                url: widget.post.user.profileImageUrl,
                radius: 18, // diameter 36
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.post.user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          color: Color(0xFF0095F6), size: 13),
                    ],
                  ],
                ),
                if (hasLocation)
                  Text(
                    widget.post.location!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showSnackbar('Follow'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showSnackbar('More options'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image / Carousel ──────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final images = widget.post.imageUrls;
    if (images.length == 1) {
      return _buildSingleImage(images[0]);
    }
    return _buildCarousel(images);
  }

  Widget _buildSingleImage(String url) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PinchToZoom(
            child: CachedNetworkImage(
              imageUrl: url,
              width: screenWidth,
              height: screenWidth,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, __) => Container(
                width: screenWidth,
                height: screenWidth,
                color: Colors.grey[900],
              ),
              errorWidget: (_, __, ___) => Container(
                width: screenWidth,
                height: screenWidth,
                color: Colors.grey[900],
                child:
                    const Icon(Icons.broken_image, color: Colors.grey, size: 48),
              ),
            ),
          ),
          if (_showHeart)
            AnimatedBuilder(
              animation: _heartScale,
              builder: (_, __) => Transform.scale(
                scale: _heartScale.value * 60,
                child:
                    const Icon(Icons.favorite, color: Colors.white, size: 1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<String> images) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: screenWidth,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              physics: const PageScrollPhysics(),
              onPageChanged: (i) {
                setState(() {
                  _currentPage = i;
                });
              },
              itemBuilder: (_, i) => PinchToZoom(
                child: CachedNetworkImage(
                  imageUrl: images[i],
                  width: screenWidth,
                  height: screenWidth,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (_, __) =>
                      Container(color: Colors.grey[900]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image,
                        color: Colors.grey, size: 48),
                  ),
                ),
              ),
            ),
          ),
          if (_showHeart)
            AnimatedBuilder(
              animation: _heartScale,
              builder: (_, __) => Transform.scale(
                scale: _heartScale.value * 60,
                child: const Icon(Icons.favorite,
                    color: Colors.white, size: 1),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicatorIfCarousel() {
    final images = widget.post.imageUrls;
    if (images.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: SmoothPageIndicator(
          controller: _pageController,
          count: images.length,
          effect: const WormEffect(
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            dotColor: Colors.grey,
            activeDotColor: Color(0xFF0095F6),
          ),
        ),
      ),
    );
  }

  // ── Actions / Caption / Meta ───────────────────────────────────────────────

  Widget _buildActionRow(bool isLiked, bool isSaved) {
    final likeCount = widget.post.likeCount + (isLiked ? 1 : 0);
    final likeFormatted = _formatCount(likeCount);
    final commentFormatted = _formatCount(widget.post.commentCount);
    // Simple derived counts for repost/share to mimic real UI
    final repostFormatted =
        _formatCount((widget.post.likeCount * 0.008).round());
    final sendFormatted =
        _formatCount((widget.post.likeCount * 0.005).round());

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          _iconWithCount(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
            label: likeFormatted,
            onTap: () =>
                context.read<FeedNotifier>().toggleLike(widget.post.id),
          ),
          const SizedBox(width: 16),
          _iconWithCount(
            icon: Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            label: commentFormatted,
            onTap: () => _showSnackbar('Comments'),
          ),
          const SizedBox(width: 16),
          _iconWithCount(
            icon: Icons.repeat_rounded,
            color: Colors.white,
            label: repostFormatted,
            onTap: () => _showSnackbar('Repost'),
          ),
          const SizedBox(width: 16),
          _iconWithCount(
            icon: Icons.send_outlined,
            color: Colors.white,
            label: sendFormatted,
            onTap: () => _showSnackbar('Share'),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                context.read<FeedNotifier>().toggleSave(widget.post.id),
            child: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconWithCount({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return '$count';
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.post.user.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const TextSpan(text: '  '),
            TextSpan(
              text: widget.post.caption,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCommentPreview() {
    return GestureDetector(
      onTap: () => _showSnackbar('Comments'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        child: Text(
          'View all ${widget.post.commentCount} comments',
          style:
              const TextStyle(color: Color(0xFF8E8E8E), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Text(
        widget.post.timeAgo,
        style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 11),
      ),
    );
  }
}

