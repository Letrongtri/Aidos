import 'package:ct312h_project/repository/post_repository.dart';
import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:ct312h_project/viewmodels/post_item_view_model.dart';
import 'package:ct312h_project/viewmodels/user_cache_manager.dart';
import 'package:flutter/widgets.dart';

class DetailPostManager extends ChangeNotifier {
  // final PostsManager postsManager;
  final PostRepository postRepo;
  final UserCacheManager userCache;
  final CommentManager commentManager;

  PostItemViewModel? _post;
  bool isLoading = false;
  String? errorMessage;

  DetailPostManager({
    required this.postRepo,
    required this.userCache,
    required this.commentManager,
    // required this.postsManager,
  });

  PostItemViewModel? get post => _post;

  // Load bài post
  Future<void> fetchPostById(String postId) async {
    // _post = postsManager.findPostByIdLocal(postId);
    // if (_post != null) {
    //   notifyListeners();
    //   return;
    // }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final post = await postRepo.getPostById(postId);

      // Lấy danh sách userId duy nhất từ các post
      await userCache.preloadUsers([post.userId]);
      final user = userCache.tryGetCached(post.userId);

      if (user == null) {
        throw Exception("Missing user ${post.userId} in cache");
      }

      // Gộp lại: post + username
      _post = PostItemViewModel.fromEntites(post: post, user: user);

      // load comments
      await commentManager.fetchCommentsByPostId(postId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> toggleLike() async {
  //   if (_post == null) return;

  //   final newLiked = !_post!.isLiked;
  //   final newCount = newLiked ? _post!.likeCount + 1 : _post!.likeCount - 1;

  //   final updatedPost = _post!.copyWith(isLiked: newLiked, likeCount: newCount);

  //   // Update local post
  //   _post = updatedPost;
  //   notifyListeners();

  //   // Đồng bộ với PostsManager
  //   postsManager.updatePostLocal(updatedPost);

  //   // Gọi repo để cập nhật backend
  //   try {
  //     // await postRepo.toggleLike(updatedPost.id, newLiked);
  //   } catch (e) {
  //     // rollback nếu backend lỗi
  //     final rollback = updatedPost.copyWith(
  //       isLiked: !newLiked,
  //       likeCount: newLiked ? newCount - 1 : newCount + 1,
  //     );
  //     _post = rollback;
  //     postsManager.updatePostLocal(rollback);
  //     notifyListeners();
  //   }
  // }

  Future<void> onLikePostPressed(String id) async {
    if (_post == null) return;
    if (_post == null || id != _post!.id) return;
    final post = _post;

    try {
      final currentLiked = _post?.isLiked ?? false;
      final updatedLikeCount = currentLiked
          ? _post!.likeCount - 1
          : _post!.likeCount + 1;

      _post = post?.copyWith(
        likeCount: updatedLikeCount,
        isLiked: !currentLiked,
      );
      notifyListeners();

      // TODO: gọi repo để cập nhật dữ liệu
      // if (currentLiked) {
      //   await postRepo.unlikePost(id);
      // } else {
      //   await postRepo.likePost(id);
      // }
    } catch (e) {
      errorMessage = e.toString();
      _post = post; // rollback
      notifyListeners();
    }
  }
}
