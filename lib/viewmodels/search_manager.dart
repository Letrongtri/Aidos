import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/services/services.dart';
import 'package:flutter/material.dart';

class SearchManager extends ChangeNotifier {
  final _postService = PostService();
  final _topicService = TopicService();

  final _likeService = LikeService();
  final _repostService = RepostService();

  String? errorMessage;
  List<Post> searchResults = [];
  List<Topic> topicSuggestions = [];
  String currentQuery = '';

  int _page = 1;
  final int _perPage = 30;
  bool _isLoadingPost = false; // load more search post
  bool _isSearching = false;
  bool _hasMorePosts = true;

  Set<String> _repostedPostIds = {};

  List<Post> get posts => [...searchResults];
  int get postCount => searchResults.length;

  List<Topic> get topic => [...topicSuggestions];
  int get topicCount => topicSuggestions.length;

  int get page => _page;
  int get perPage => _perPage;
  bool get isLoadingPost => _isLoadingPost;
  bool get isSearching => _isSearching;
  bool get hasMorePosts => _hasMorePosts;

  Future<void> fetchSuggestionTopics() async {
    try {
      topicSuggestions = await _topicService.fetchTopics();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<List<Post>> _enrichPostsWithInteractionState(
    List<Post> rawPosts,
  ) async {
    if (rawPosts.isEmpty) return [];

    final postIds = rawPosts.map((p) => p.id).toList();

    final likedIds = await _likeService.fetchLikedPostIds(postIds);
    _repostedPostIds = await _repostService.fetchRepostedPostIds(postIds);

    return rawPosts.map((p) {
      return p.copyWith(isLiked: likedIds.contains(p.id));
    }).toList();
  }

  Future<List<Post>> _fetchTrendingPosts() async {
    int perPage = 10;

    List<Post> posts = [];
    try {
      final rawPosts = await _postService.fetchTrendingPosts(perPage: perPage);

      posts = await _enrichPostsWithInteractionState(rawPosts);

      searchResults = posts;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isSearching = false;
      _hasMorePosts = false;
      notifyListeners();
    }
    return posts;
  }

  Future<void> search(String? query, {bool isRefresh = false}) async {
    if (isSearching || isLoadingPost) return;

    if (!hasMorePosts) return;

    if (isRefresh) {
      _isSearching = true;
      _page = 1;
      _hasMorePosts = true;
      searchResults.clear();
    }

    _isLoadingPost = true;
    notifyListeners();

    try {
      if (query == null || query.isEmpty) {
        searchResults = await _fetchTrendingPosts();
        notifyListeners();
        return;
      }

      final currentQuery = query.trim().toLowerCase();
      final keywords = currentQuery.split(RegExp(r'\s+'));

      final posts = await _postService.findPostByKeywords(
        keywords,
        page: _page,
        perPage: _perPage,
      );

      if (posts.length < _perPage) {
        _hasMorePosts = false;
      } else {
        _page++;
      }

      if (posts.isEmpty) {
        searchResults = [];
        notifyListeners();
        return;
      }

      searchResults.addAll(posts);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (isRefresh) _isSearching = false;
      _isLoadingPost = false;
      notifyListeners();
    }
  }

  bool hasUserReposted(String postId) {
    return _repostedPostIds.contains(postId);
  }

  Future<void> onLikePostPressed(String id) async {
    final index = searchResults.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final post = searchResults[index];
    final isLiked = post.isLiked ?? false;
    final likeCount = post.likes;

    searchResults[index] = post.copyWith(
      isLiked: !isLiked,
      likes: isLiked ? likeCount - 1 : likeCount + 1,
    );
    notifyListeners();

    // Gọi API thực tế
    try {
      if (isLiked) {
        await _likeService.unlikePost(id, likeCount);
      } else {
        await _likeService.likePost(id, likeCount);
      }
    } catch (e) {
      debugPrint('Error toggling like in search: $e');
    }
  }
}
