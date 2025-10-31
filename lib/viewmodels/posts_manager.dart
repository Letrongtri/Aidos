import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/services/like_service.dart';
import 'package:ct312h_project/services/post_service.dart';
import 'package:flutter/material.dart';

class PostsManager extends ChangeNotifier {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  final List<Post> _posts = [];
  String? errorMessage;

  int get postCount {
    return _posts.length;
  }

  List<Post> get posts {
    return [..._posts];
  }

  Future<void> fetchPosts() async {
    try {
      final fetchedPosts = await _postService.fetchPosts();

      List<Post> posts = [];
      List<String> postIds = [];

      // Chỉ thêm comment mới, tránh trùng
      for (final post in fetchedPosts) {
        if (!_posts.any((p) => p.id == post.id)) {
          posts.add(post);
          postIds.add(post.id);
        }
      }

      final likedPostIds = await _likeService.fetchLikedPostIds(postIds);

      posts = posts
          .map((p) => p.copyWith(isLiked: likedPostIds.contains(p.id)))
          .toList();

      _posts.addAll(posts);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Post? findPostById(String id) {
    try {
      return _posts.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }

  Future<void> updatePostLocal(Post updatedPost) async {
    final idx = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (idx == -1) return;
    _posts[idx] = updatedPost;
    notifyListeners();
  }

  Future<void> onLikePostPressed(String id) async {
    try {
      void toggleLike(List<Post> list) {
        final index = list.indexWhere((p) => p.id == id);
        if (index != -1) {
          final post = list[index];
          final isLiked = post.isLiked ?? false;
          final updated = post.copyWith(
            isLiked: !isLiked,
            likes: isLiked ? post.likes - 1 : post.likes + 1,
          );
          list[index] = updated;
        }
      }

      toggleLike(_posts);
      toggleLike(userPosts);
      toggleLike(repliedPosts);

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  void incrementCommentCount(String postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final newCount = _posts[postIndex].comments + 1;
      _posts[postIndex] = _posts[postIndex].copyWith(comments: newCount);
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

      _posts.insert(0, newPost);
      errorMessage = null;
      await fetchUserPosts(userId);

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error creating post: $errorMessage');
      notifyListeners();
    }
  }

  List<Post> userPosts = [];
  List<Post> repliedPosts = [];
  List<Post> reposts = [];

  Future<void> fetchUserPosts(String userId) async {
    try {
      userPosts = await _postService.fetchPostsByUser(userId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error fetching user posts: $errorMessage');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchRepliedPosts(String userId) async {
    try {
      repliedPosts = await _postService.fetchRepliedPosts(userId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error fetching replied posts: $errorMessage');
    } finally {
      notifyListeners();
    }
  }

  // Future<void> fetchReposts(String userId) async {
  //   try {
  //     reposts = await _postService.fetchReposts(userId);
  //     errorMessage = null;
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     debugPrint('Error fetching reposts: $errorMessage');
  //   } finally {
  //     notifyListeners();
  //   }
  // }
}
