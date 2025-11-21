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

  Set<String> _repostedPostIds = {};

  List<Post> get posts => [...searchResults];
  int get postCount => searchResults.length;

  List<Topic> get topic => [...topicSuggestions];
  int get topicCount => topicSuggestions.length;

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

  Future<List<Post>> fetchTrendingPosts() async {
    List<Post> posts = [];
    try {
      final rawPosts = await _postService.fetchPosts();

      posts = await _enrichPostsWithInteractionState(rawPosts);

      searchResults = posts;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
    return posts;
  }

  Future<void> search(String? query) async {
    try {
      if (query == null || query.isEmpty) {
        await fetchTrendingPosts();
        return;
      }

      final currentQuery = query.trim().toLowerCase();
      final keywords = currentQuery.split(RegExp(r'\s+'));

      final rawPosts = await _postService.findPostByKeywords(keywords);

      if (rawPosts.isEmpty) {
        searchResults = [];
        notifyListeners();
        return;
      }

      searchResults = await _enrichPostsWithInteractionState(rawPosts);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
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
