import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/like_service.dart';
import 'package:ct312h_project/services/post_service.dart';
import 'package:flutter/material.dart';

class PostsManager extends ChangeNotifier {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  List<Post> _posts = [];
  final List<Post> _repliedPosts = [];

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

  Future<Post?> createPost({
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
      notifyListeners();

      return newPost;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("createPost error: $e");

      rethrow;
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
    final index = _posts.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final post = _posts[index];
    final isLiked = post.isLiked ?? false;
    final likeCount = post.likes;

    try {
      // Gọi service (service sẽ đếm lại từ DB)
      if (isLiked) {
        await _likeService.unlikePost(id, likeCount);
      } else {
        await _likeService.likePost(id, likeCount);
      }

      // Đợi một chút để đảm bảo DB đã commit
      await Future.delayed(Duration(milliseconds: 200));

      // Refresh post từ database để có số liệu chính xác
      await _refreshPost(id);

      debugPrint('✅ Like toggled successfully, UI updated from DB');
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      // Có thể hiện snackbar báo lỗi cho user ở đây
    }
  }

  Future<void> _refreshPost(String id) async {
    try {
      debugPrint('🔄 Starting refresh for post: $id');

      final updatedPost = await _postService.fetchPostById(id);
      debugPrint('🔄 Fetched post from DB: likes=${updatedPost?.likes}');

      if (updatedPost != null) {
        final index = _posts.indexWhere((p) => p.id == id);
        debugPrint('🔄 Post index in list: $index');

        if (index != -1) {
          final oldLikes = _posts[index].likes;

          // Lấy trạng thái isLiked từ database
          final likedIds = await _likeService.fetchLikedPostIds([id]);
          _posts[index] = updatedPost.copyWith(isLiked: likedIds.contains(id));

          debugPrint(
            '🔄 Updated post: oldLikes=$oldLikes, newLikes=${_posts[index].likes}, isLiked=${likedIds.contains(id)}',
          );

          notifyListeners();
        }
      } else {
        debugPrint('❌ updatedPost is null!');
      }
    } catch (e) {
      debugPrint("❌ Error refreshing post: $e");
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

  Future<List<Map<String, dynamic>>> getUserRepliedPosts(String userId) async {
    return await _postService.fetchRepliedPosts(userId);
  }

  void updateUserInfoInPosts(User updatedUser) {
    for (int i = 0; i < _posts.length; i++) {
      final post = _posts[i];
      if (post.userId == updatedUser.id) {
        _posts[i] = post.copyWith(user: updatedUser);
      }
    }
    notifyListeners();
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    String? topicName,
  }) async {
    try {
      final updatedPost = await _postService.updatePost(
        postId: postId,
        content: content,
        topicName: topicName,
      );

      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("updatePost error: $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      debugPrint("deletePost error: $e");
      rethrow;
    }
  }
}
