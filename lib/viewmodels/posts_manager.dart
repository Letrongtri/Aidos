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

  // void addPost(PostItemViewModel post) {
  //   _posts.add(post);
  //   notifyListeners();
  // }

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
    // final index = _posts.indexWhere((p) => p.id == id);
    // if (index == -1) return;
    // final post = _posts[index];

    // try {
    //   final currentLiked = post.isLiked;
    //   final updatedLikeCount = currentLiked
    //       ? post.likeCount - 1
    //       : post.likeCount + 1;

    //   _posts[index] = post.copyWith(
    //     likeCount: updatedLikeCount,
    //     isLiked: !currentLiked,
    //   );
    //   notifyListeners();

    // TODO: gọi repo để cập nhật dữ liệu
    // if (currentLiked) {
    //   await postRepo.unlikePost(id);
    // } else {
    //   await postRepo.likePost(id);
    // }
    // } catch (e) {
    //   errorMessage = e.toString();
    //   _posts[index] = post; // rollback
    //   notifyListeners();
    // }
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
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error creating post: $errorMessage');
      notifyListeners();
    }
  }
}
