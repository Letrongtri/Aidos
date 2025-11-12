import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/like_service.dart';
import 'package:ct312h_project/services/post_service.dart';
import 'package:ct312h_project/services/repost_service.dart';
import 'package:flutter/material.dart';

class PostsManager extends ChangeNotifier {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();
  final RepostService _repostService = RepostService();

  List<Post> _posts = [];
  final List<Post> _repliedPosts = [];

  Set<String> _repostedPostIds = {};

  String? errorMessage;

  List<Post> get posts => List<Post>.from(_posts);
  List<Post> get repliedPosts => List<Post>.from(_repliedPosts);

  Future<void> fetchPosts() async {
    try {
      final fetched = await _postService.fetchPosts();
      final postIds = fetched.map((p) => p.id).toList();

      final likedIds = await _likeService.fetchLikedPostIds(postIds);
      _repostedPostIds = await _repostService.fetchRepostedPostIds(postIds);

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
      if (isLiked) {
        await _likeService.unlikePost(id, likeCount);
      } else {
        await _likeService.likePost(id, likeCount);
      }

      await Future.delayed(Duration(milliseconds: 200));
      await _refreshPost(id);

      debugPrint('Like toggled successfully, UI updated from DB');
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> onRepostPressed(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final post = _posts[index];
    final isReposted = _repostedPostIds.contains(id);
    final repostCount = post.reposts;

    try {
      if (isReposted) {
        await _repostService.unrepostPost(id, repostCount);
        _repostedPostIds.remove(id);
      } else {
        await _repostService.repostPost(id, repostCount);
        _repostedPostIds.add(id);
      }

      await Future.delayed(Duration(milliseconds: 200));
      await _refreshPost(id);

      debugPrint('Repost toggled successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling repost: $e');
    }
  }

  bool hasUserReposted(String postId) {
    return _repostedPostIds.contains(postId);
  }

  Future<void> _refreshPost(String id) async {
    try {
      debugPrint('Starting refresh for post: $id');

      final updatedPost = await _postService.fetchPostById(id);
      debugPrint(
        'Fetched post from DB: likes=${updatedPost?.likes}, reposts=${updatedPost?.reposts}',
      );

      if (updatedPost != null) {
        final index = _posts.indexWhere((p) => p.id == id);
        debugPrint('🔄 Post index in list: $index');

        if (index != -1) {
          final oldLikes = _posts[index].likes;
          final oldReposts = _posts[index].reposts;

          final likedIds = await _likeService.fetchLikedPostIds([id]);

          final isReposted = await _repostService.hasUserReposted(id);
          if (isReposted) {
            _repostedPostIds.add(id);
          } else {
            _repostedPostIds.remove(id);
          }

          _posts[index] = updatedPost.copyWith(isLiked: likedIds.contains(id));

          debugPrint(
            '🔄 Updated post: oldLikes=$oldLikes, newLikes=${_posts[index].likes}, isLiked=${likedIds.contains(id)}, oldReposts=$oldReposts, newReposts=${_posts[index].reposts}, isReposted=$isReposted',
          );

          notifyListeners();
        }
      } else {
        debugPrint('updatedPost is null!');
      }
    } catch (e) {
      debugPrint("Error refreshing post: $e");
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

  Future<List<Post>> getUserRepostedPosts(String userId) async {
    try {
      final repostedPostIds = await _repostService.fetchUserRepostedPostIds(
        userId,
      );

      final repostedPosts = <Post>[];
      for (final postId in repostedPostIds) {
        final cachedPost = _posts.firstWhere(
          (p) => p.id == postId,
          orElse: () => Post.empty(),
        );

        if (cachedPost.id.isNotEmpty) {
          repostedPosts.add(cachedPost);
        } else {
          final post = await _postService.fetchPostById(postId);
          if (post != null) {
            repostedPosts.add(post);
          }
        }
      }

      return repostedPosts;
    } catch (e) {
      debugPrint('Error getting user reposted posts: $e');
      return [];
    }
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
