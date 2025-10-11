import 'package:ct312h_project/repository/post_repository.dart';
import 'package:ct312h_project/viewmodels/post_item_view_model.dart';
import 'package:ct312h_project/viewmodels/topic_manager.dart';
import 'package:ct312h_project/viewmodels/user_cache_manager.dart';
import 'package:flutter/material.dart';

class PostsManager extends ChangeNotifier {
  final PostRepository postRepo;
  final TopicManager topicCache;
  final UserCacheManager userCache;

  List<PostItemViewModel> _posts = [];
  bool isLoading = false;
  String? errorMessage;

  PostsManager({
    required this.postRepo,
    required this.userCache,
    required this.topicCache,
  });

  int get postCount {
    return _posts.length;
  }

  List<PostItemViewModel> get posts {
    return [..._posts];
  }

  // void addPost(PostItemViewModel post) {
  //   _posts.add(post);
  //   notifyListeners();
  // }

  Future<PostItemViewModel> findPostById(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final post = await postRepo.getPostById(id);
      final user = await userCache.getUser(post.userId);
      final topic = await topicCache.getTopicById(post.topicId);

      return PostItemViewModel.fromEntites(
        post: post,
        user: user,
        topic: topic,
      );
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  PostItemViewModel? findPostByIdLocal(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updatePostLocal(PostItemViewModel updatedPost) async {
    final idx = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (idx == -1) return;
    _posts[idx] = updatedPost;
    notifyListeners();
  }

  Future<void> fetchPostsViewModel() async {
    if (isLoading) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final posts = await postRepo.fetchPosts();

      final topicIds = <String>[];
      final userIds = <String>[];

      for (var post in posts) {
        userIds.add(post.userId);

        if (post.topicId.isNotEmpty == true) {
          topicIds.add(post.topicId);
        }
      }

      await Future.wait([
        // lấy Topic name (nếu có)
        if (topicIds.isNotEmpty) topicCache.preloadTopics(topicIds.toList()),
        // Lấy danh sách userId duy nhất từ các post
        if (userIds.isNotEmpty) userCache.preloadUsers(userIds.toList()),
      ]);

      // Gộp lại: post + username + topicname
      _posts = posts.map((post) {
        final user = userCache.tryGetCached(post.userId);

        if (user == null) {
          throw Exception("Missing user ${post.userId} in cache");
        }

        final topic = post.topicId.isNotEmpty
            ? topicCache.tryGetCached(post.topicId)
            : null;

        return PostItemViewModel.fromEntites(
          post: post,
          user: user,
          topic: topic,
          isLiked: false,
        );
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onLikePostPressed(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final post = _posts[index];

    try {
      final currentLiked = post.isLiked;
      final updatedLikeCount = currentLiked
          ? post.likeCount - 1
          : post.likeCount + 1;

      _posts[index] = post.copyWith(
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
      _posts[index] = post; // rollback
      notifyListeners();
    }
  }
}
