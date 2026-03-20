// lib/providers/feed_provider.dart

import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../services/post_repository.dart';

/// Feed / Post provider using the `provider` package.
/// Manages:
/// - posts list
/// - pagination
/// - loading / error
/// - stories
/// - like / save state
class FeedNotifier extends ChangeNotifier {
  final PostRepository _repo;

  FeedNotifier(this._repo) {
    _loadInitial();
  }

  final List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasError = false;
  int _currentPage = 0;

  final List<StoryModel> _stories = [];
  bool _isStoriesLoading = false;

  final Set<String> _liked = {};
  final Set<String> _saved = {};

  UnmodifiableListView<PostModel> get posts =>
      UnmodifiableListView<PostModel>(_posts);
  UnmodifiableListView<StoryModel> get stories =>
      UnmodifiableListView<StoryModel>(_stories);

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasError => _hasError;
  int get currentPage => _currentPage;

  bool get isStoriesLoading => _isStoriesLoading;

  bool isLiked(String id) => _liked.contains(id);
  bool isSaved(String id) => _saved.contains(id);

  // ── Initial load ───────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final posts = await _repo.fetchPosts(page: 0);
      _posts
        ..clear()
        ..addAll(posts);
      _currentPage = 0;
      _isLoading = false;
      _hasError = false;
      notifyListeners();
      _loadStories();
    } catch (_) {
      _isLoading = false;
      _hasError = true;
      notifyListeners();
    }
  }

  Future<void> reload() => _loadInitial();

  // ── Pagination ─────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final newPosts = await _repo.fetchPosts(page: nextPage);
      _posts.addAll(newPosts);
      _currentPage = nextPage;
      _isFetchingMore = false;
      notifyListeners();
    } catch (_) {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // ── Stories ────────────────────────────────────────────────────────────────

  Future<void> _loadStories() async {
    _isStoriesLoading = true;
    notifyListeners();
    try {
      final data = await _repo.fetchStories();
      _stories
        ..clear()
        ..addAll(data);
    } finally {
      _isStoriesLoading = false;
      notifyListeners();
    }
  }

  // ── Like / Save ────────────────────────────────────────────────────────────

  void toggleLike(String postId) {
    if (_liked.contains(postId)) {
      _liked.remove(postId);
    } else {
      _liked.add(postId);
    }
    notifyListeners();
  }

  void toggleSave(String postId) {
    if (_saved.contains(postId)) {
      _saved.remove(postId);
    } else {
      _saved.add(postId);
    }
    notifyListeners();
  }
}
