import 'dart:async';

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/notification.dart' as notification_model;
import 'package:ct312h_project/services/services.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';

class PostsManager extends ChangeNotifier {
  final PostService _postService = PostService();
  final LikeService _likeService = LikeService();

  AuthManager? _authManager;

  StreamSubscription? _realtimeSubscription;

  List<Post> _posts = [];
  int _postsPage = 1;
  final int _postsPerPage = 20;
  final List<Post> _repliedPosts = [];

  final Set<String> _feedPostIds = {};
  final Set<String> _repostedPostIds = {};
  final Set<String> _userPostIds = {};

  bool _isLoadingPostsInitial = false;
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;
  String? errorMessage;

  // List<Post> get posts => List<Post>.from(_posts);
  List<Post> get repliedPosts => List<Post>.from(_repliedPosts);
  bool get isLoadingPostsInitial => _isLoadingPostsInitial;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get hasMorePosts => _hasMorePosts;

  get currentUser => _authManager?.user;
  bool get isLoadingUser => _authManager?.isLoading ?? false;

  List<Post> get posts => _feedPostIds
      .map((id) {
        try {
          return _posts.firstWhere((post) => post.id == id);
        } catch (e) {
          return null;
        }
      })
      .whereType<Post>() // Lọc bỏ null
      .toList();

  List<Post> get userPosts => _userPostIds
      .map((id) {
        try {
          return _posts.firstWhere((post) => post.id == id);
        } catch (e) {
          return null;
        }
      })
      .whereType<Post>()
      .toList();

  List<Post> get userReposts => _repostedPostIds
      .map((id) {
        try {
          return _posts.firstWhere((post) => post.id == id);
        } catch (e) {
          return null;
        }
      })
      .whereType<Post>()
      .toList();

  PostsManager() {
    startRealtimeUpdates();
  }

  void updateAuthUser(AuthManager auth) {
    _authManager = auth;

    if (auth.user != null) {
      for (int i = 0; i < _posts.length; i++) {
        final post = _posts[i];
        if (post.userId == auth.user!.id) {
          _posts[i] = post.copyWith(user: auth.user);
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchFeedPosts({bool isRefresh = false}) async {
    if (_isLoadingPosts) return;

    if (isRefresh) {
      _isLoadingPostsInitial = true;
      _postsPage = 1;
      _hasMorePosts = true;
      _feedPostIds.clear();
      notifyListeners();
    }

    if (!_hasMorePosts) return;

    _isLoadingPosts = true;
    notifyListeners();

    final currentUser = _authManager?.user;
    try {
      final fetched = await _postService.fetchPosts(
        currentUser?.id,
        page: _postsPage,
        perPage: _postsPerPage,
      );

      if (fetched.length < _postsPerPage) {
        _hasMorePosts = false;
      } else {
        _postsPage++;
      }

      final postIds = fetched.map((p) => p.id).toList();

      final likedIds = await _likeService.fetchLikedPostIds(postIds);

      final newPosts = fetched
          .map((p) => p.copyWith(isLiked: likedIds.contains(p.id)))
          .toList();

      for (final post in newPosts) {
        _feedPostIds.add(post.id);

        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;
        } else {
          _posts.add(post);
        }
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("fetchPosts error: $e");
    } finally {
      if (isRefresh) _isLoadingPostsInitial = false;
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<Post?> createPost({
    required String content,
    String? topicName,
    List<XFile>? images,
  }) async {
    final currentUser = _authManager?.user;
    if (currentUser == null) {
      throw Exception('User is not logged in. Cannot create post.');
    }

    try {
      final newPost = await _postService.createPostWithTopicName(
        userId: currentUser.id,
        content: content,
        topicName: topicName,
        images: images,
      );

      _posts = [newPost, ..._posts];
      errorMessage = null;
      notifyListeners();

      final notiId = Generate.generatePocketBaseId();

      final newNoti = notification_model.Notification(
        id: notiId,
        userId: currentUser.id,
        title: 'Đăng bài viết',
        body: 'Bạn đã đăng thành công 1 bài viết',
        type: notification_model.NotificationType.post.name,
        targetId: newPost.id,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      await PocketBaseNotificationService.createNotification(newNoti);

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

    _posts[index] = post.copyWith(
      isLiked: !isLiked,
      likes: isLiked ? likeCount - 1 : likeCount + 1,
    );
    notifyListeners();

    try {
      if (isLiked) {
        await _likeService.unlikePost(id, likeCount);
      } else {
        await _likeService.likePost(id, likeCount);

        final currentUserId = await getCurrentUserId();
        if (currentUserId != null && currentUserId != post.userId) {
          final notiId = Generate.generatePocketBaseId();

          final newNoti = notification_model.Notification(
            id: notiId,
            userId: post.userId,
            title: 'Yêu thích bài viết',
            body: 'Ai đó đã yêu thích bài viết của bạn',
            type: notification_model.NotificationType.like.name,
            targetId: post.id,
            created: DateTime.now(),
            updated: DateTime.now(),
          );
          await PocketBaseNotificationService.createNotification(newNoti);
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> refreshPost(String id) async {
    try {
      final updatedPost = await _postService.fetchPostById(id);

      if (updatedPost != null) {
        final index = _posts.indexWhere((p) => p.id == id);

        if (index != -1) {
          final likedIds = await _likeService.fetchLikedPostIds([id]);

          _posts[index] = updatedPost.copyWith(isLiked: likedIds.contains(id));

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error refreshing post: $e");
    }
  }

  Future<void> getUserPosts(String userId) async {
    try {
      final posts = await _postService.fetchPostsByUser(userId);

      // nếu đã có trong post thì bỏ qua, k thì thêm vào post
      for (final post in posts) {
        _userPostIds.add(post.id);

        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;
        } else {
          _posts.add(post);
        }
      }
    } catch (e) {
      debugPrint('Error getting user posts: $e');
    }
  }

  Future<void> getUserReposts(String userId) async {
    try {
      final reposts = await _postService.fetchRepostsByUser(userId);

      // nếu đã có trong post thì bỏ qua, k thì thêm vào post
      for (final post in reposts) {
        _repostedPostIds.add(post.id);

        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;
        } else {
          _posts.add(post);
        }
      }
    } catch (e) {
      debugPrint('Error getting user posts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserRepliedPosts(String userId) async {
    return await _postService.fetchRepliedPosts(userId);
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    String? topicName,
    List<XFile>? images,
  }) async {
    try {
      final updatedPost = await _postService.updatePost(
        postId: postId,
        content: content,
        topicName: topicName,
        images: images,
      );

      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("updatePost error: $e");
      rethrow;
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

  Future<void> createRepost({
    String? content,
    required String parentPostId,
  }) async {
    final currentUser = _authManager?.user;
    if (currentUser == null) {
      throw Exception('User is not logged in. Cannot create post.');
    }

    final parentPost = _posts.firstWhere((post) => post.id == parentPostId);

    try {
      final newPost = await _postService.createRepost(
        userId: currentUser.id,
        parentPostId: parentPostId,
        content: content,
      );

      _posts = [
        newPost.copyWith(user: currentUser, parentPost: parentPost),
        ..._posts,
      ];
      errorMessage = null;
      notifyListeners();

      if (parentPost.userId != currentUser.id) {
        final notiId = Generate.generatePocketBaseId();
        final newNoti = notification_model.Notification(
          id: notiId,
          userId: parentPost.userId,
          title: 'Đăng lại mới',
          body: 'Ai đó đã đăng lại bài viết của bạn',
          type: notification_model.NotificationType.post.name,
          targetId: newPost.id,
          created: DateTime.now(),
          updated: DateTime.now(),
        );
        await PocketBaseNotificationService.createNotification(newNoti);
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Create repost error: $e");
      rethrow;
    }
  }

  void startRealtimeUpdates() {
    _realtimeSubscription?.cancel();

    _realtimeSubscription = _postService.subscribeToPost().listen((event) {
      _handleRealtimeEvent(event);
    });
  }

  void _handleRealtimeEvent(RecordSubscriptionEvent event) {
    if (event.action == 'update') {
      final updatedRecordId = event.record!.id;

      final index = _posts.indexWhere((p) => p.id == updatedRecordId);

      if (index != -1) {
        final oldPost = _posts[index];

        final updatedPost = oldPost.copyWithRawData(
          event.record!.data,
          oldPost.isLiked,
          oldPost.parentPost,
        );

        _posts[index] = updatedPost;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
