// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_widget.dart';
import '../widgets/shimmer_post.dart';
import '../widgets/story_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final feed = context.read<FeedNotifier>();
    if (feed.isFetchingMore) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll - currentScroll <= 800) {
      feed.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedNotifier>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        // ── Bottom Navigation Bar ──────────────────────────────────────────
        bottomNavigationBar: _buildBottomNavBar(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(),
              const Divider(color: Color(0xFF262626), height: 1),
              Expanded(
                child: feed.isLoading
                    ? _buildShimmerFeed()
                    : feed.hasError
                        ? _buildError()
                        : _buildFeed(feed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top App Bar ───────────────────────────────────────────────────────────
  // Layout: [+]  [   Instagram (centered)   ]  [♡]

  Widget _buildTopBar() {
    return Container(
      height: 56,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Instagram',
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w400,
              fontFamily: 'Billabong',
              height: 1.0,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.add,
                  color: Colors.white, size: 26),
              padding: EdgeInsets.zero,
              splashRadius: 22,
              onPressed: () => _showSnackbar('Create'),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.favorite_border,
                  color: Colors.white, size: 26),
              padding: EdgeInsets.zero,
              splashRadius: 22,
              onPressed: () => _showSnackbar('Notifications'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────
  // Matches real Instagram: Home | Reels | Send(with dot) | Search | Profile

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF262626), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _navItem(0, _HomeIcon(filled: _currentNavIndex == 0)),
              // 2. Reels (play button in circle — matches Instagram)
              _navItem(1, Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
                size: 30,
              )),
              // 3. Send / DM (paper plane with notification dot)
              _navItemWithDot(2),
              // 4. Search
              _navItem(3, Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              )),
              // 5. Profile avatar
              _profileNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, Widget iconWidget) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 0) {
          // Home tab tapped: keep it selected and smoothly scroll feed to top.
          setState(() => _currentNavIndex = 0);
          if (_scrollController.hasClients) {
            final current = _scrollController.offset;
            if (current <= 0) return;
            // Duration scales with distance for a more natural feel.
            final baseMs = 250;
            final extraMs = (current / 1200 * 350).clamp(0, 450).toInt();
            final duration = Duration(milliseconds: baseMs + extraMs);
            _scrollController.animateTo(
              0,
              duration: duration,
              curve: Curves.easeOutCubic,
            );
          }
        } else {
          setState(() => _currentNavIndex = index);
          _showSnackbar(_navLabel(index));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: iconWidget,
      ),
    );
  }

  // Send icon with a small red notification dot (like real Instagram)
  Widget _navItemWithDot(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _currentNavIndex = index);
        _showSnackbar(_navLabel(index));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.send_outlined,
              color: Colors.white,
              size: 28,
            ),
            // Red dot badge
            Positioned(
              top: -2,
              right: -4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3040),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileNavItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _currentNavIndex = 4);
        _showSnackbar('Profile');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _currentNavIndex == 4 ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _navLabel(int index) {
    switch (index) {
      case 1: return 'Reels';
      case 2: return 'Direct Messages';
      case 3: return 'Search';
      case 4: return 'Profile';
      default: return '';
    }
  }

  void _showSnackbar(String label) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label coming soon!',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF262626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  // ── Shimmer Feed ──────────────────────────────────────────────────────────

  Widget _buildShimmerFeed() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const ShimmerStories(),
          const Divider(color: Color(0xFF262626), height: 1),
          ...List.generate(3, (_) => const ShimmerPost()),
        ],
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          const Text('Something went wrong.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<FeedNotifier>().reload(),
            child: const Text('Retry',
                style: TextStyle(color: Color(0xFF0095F6))),
          ),
        ],
      ),
    );
  }

  // ── Main Feed ─────────────────────────────────────────────────────────────

  Widget _buildFeed(FeedNotifier feed) {
    final screenHeight = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xFF262626),
      displacement: 20,
      onRefresh: () => context.read<FeedNotifier>().reload(),
      child: CustomScrollView(
        controller: _scrollController,
        // Smooth, iOS-style physics on all platforms
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // Pre-render roughly 1.5 screens ahead for smoother scroll
        cacheExtent: screenHeight * 1.5,
        slivers: [
          const SliverToBoxAdapter(child: StoriesTray()),
          const SliverToBoxAdapter(
            child: Divider(color: Color(0xFF262626), height: 1),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => PostCard(
                key: ValueKey(feed.posts[index].id),
                post: feed.posts[index],
              ),
              childCount: feed.posts.length,
            ),
          ),
          SliverToBoxAdapter(
            child: feed.isFetchingMore
                ? _buildPaginationLoader()
                : const SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return const Column(
      children: [ShimmerPost(), ShimmerPost()],
    );
  }
}

// ── Custom Home Icon ───────────────────────────────────────────────────────
// Draws the Instagram-style filled/outlined house icon using CustomPainter

class _HomeIcon extends StatelessWidget {
  final bool filled;
  const _HomeIcon({required this.filled});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _HousePainter(filled: filled),
    );
  }
}

class _HousePainter extends CustomPainter {
  final bool filled;
  const _HousePainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Roof (triangle)
    final roofPath = Path()
      ..moveTo(w * 0.5, h * 0.05)   // peak
      ..lineTo(w * 0.97, h * 0.45)  // right eave
      ..lineTo(w * 0.03, h * 0.45)  // left eave
      ..close();
    canvas.drawPath(roofPath, paint);

    // House body
    final bodyPath = Path()
      ..moveTo(w * 0.1, h * 0.44)
      ..lineTo(w * 0.1, h * 0.95)
      ..lineTo(w * 0.9, h * 0.95)
      ..lineTo(w * 0.9, h * 0.44);
    canvas.drawPath(bodyPath, paint);

    // Door (only drawn as outline even when filled)
    final doorPaint = Paint()
      ..color = filled ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;

    final doorPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.36, h * 0.60, w * 0.28, h * 0.35),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ));

    if (filled) {
      canvas.drawPath(doorPath, doorPaint);
    } else {
      canvas.drawPath(doorPath, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_HousePainter old) => old.filled != filled;
}
