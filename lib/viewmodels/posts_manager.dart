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
      List<Post> posts = await _postService.fetchPosts();
      final postIds = posts.map((p) => p.id).toList();
      final likedPostIds = await _likeService.fetchLikedPostIds(postIds);
      print(likedPostIds);
      posts = posts
          .map((p) => p.copyWith(isLiked: likedPostIds.contains(p.id)))
          .toList();

      _posts.addAll(
        posts.map((p) => p.copyWith(isLiked: likedPostIds.contains(p.id))),
      );
    } catch (e) {
      print(e);
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

  Future<void> createPost({
    required String userId,
    required String content,
    String? topicId,
  }) async {
    try {
      final newPost = await _postService.createPost(
        userId: userId,
        content: content,
        topicId: topicId,
      );

      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
