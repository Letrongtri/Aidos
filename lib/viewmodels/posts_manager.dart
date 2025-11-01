import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/services/like_service.dart';
import 'package:ct312h_project/services/post_service.dart';
import 'package:flutter/material.dart';

class PostsManager extends ChangeNotifier {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  List<Post> _posts = [];
  List<Post> _repliedPosts = [];
  bool _isFetchingReplied = false;

  String? errorMessage;

  List<Post> get posts => List<Post>.from(_posts);
  List<Post> get repliedPosts => List<Post>.from(_repliedPosts);

  Future<void> fetchPosts() async {
    try {
      final fetched = await _postService.fetchPosts();
      final postIds = fetched.map((p) => p.id).toList();
      final likedIds = await _likeService.fetchLikedPostIds(postIds);

      _posts = fetched
          .map((p) => p.copyWith(isLiked: likedIds.contains(p.id)))
          .toList();

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("fetchPosts error: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String userId,
    required String content,
    String? topicName,
  }) async {
    try {
      final newPost = await _postService.createPostWithTopicName(
        userId: userId,
        content: content,
        topicName: topicName,
      );

      _posts = [newPost, ..._posts];
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("createPost error: $e");
    } finally {
      notifyListeners();
    }
  }

  Post? findPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> onLikePostPressed(String id) async {
    try {
      final index = _posts.indexWhere((p) => p.id == id);
      if (index == -1) return;

      final post = _posts[index];
      final isLiked = post.isLiked ?? false;
      final likeCount = post.likes;

      final updated = post.copyWith(
        isLiked: !isLiked,
        likes: isLiked ? likeCount - 1 : likeCount + 1,
      );

      _posts[index] = updated;
      notifyListeners();

      if (isLiked) {
        await _likeService.unlikePost(id, likeCount);
      } else {
        await _likeService.likePost(id, likeCount);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  void incrementCommentCount(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(comments: post.comments + 1);
      notifyListeners();
    }
  }

  List<Post> getUserPosts(String userId) {
    return _posts.where((p) => p.userId == userId).toList();
  }

  Future<List<Post>> getUserRepliedPosts(String userId) async {
    if (_isFetchingReplied) return List<Post>.from(_repliedPosts);
    _isFetchingReplied = true;

    try {
      final replied = await _postService.fetchRepliedPosts(userId);
      _repliedPosts = List<Post>.from(replied);

      for (final post in replied) {
        if (!_posts.any((p) => p.id == post.id)) {
          _posts.add(post);
        }
      }

      errorMessage = null;
      return List<Post>.from(_repliedPosts);
    } catch (e) {
      debugPrint("Error fetching replied posts: $e");
      errorMessage = e.toString();
      return [];
    } finally {
      _isFetchingReplied = false;
      notifyListeners();
    }
  }
}
