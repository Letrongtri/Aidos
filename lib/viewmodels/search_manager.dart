import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/models/notification.dart' as notification_model;
import 'package:ct312h_project/services/services.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';

class SearchManager extends ChangeNotifier {
  final _postService = PostService();
  final _topicService = TopicService();
  final _likeService = LikeService();
  final _repostService = RepostService();

  PostsManager? _postsManager;

  void update(PostsManager manager) {
    if (_postsManager != manager) {
      _postsManager?.removeListener(_onPostsManagerChanged);
      _postsManager = manager;
      _postsManager?.addListener(_onPostsManagerChanged);
    }
  }

  void _onPostsManagerChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _postsManager?.removeListener(_onPostsManagerChanged);
    super.dispose();
  }

  String? errorMessage;
  List<Post> _localSearchResults = [];
  List<Topic> topicSuggestions = [];
  String currentQuery = '';

  final Set<String> _repostedPostIds = {};

  int _page = 1;
  final int _perPage = 30;
  bool _isLoadingPost = false; // load more search post
  bool _isSearching = false;
  bool _hasMorePosts = true;

  List<Post> get posts {
    return _localSearchResults.map((localPost) {
      // Thử tìm xem bài này có bên PostsManager (Feed) không?
      // Nếu có bên Feed -> Dùng bản của Feed (để đồng bộ Like/Repost)
      // Nếu không -> Dùng bản local
      final feedPost = _postsManager?.findPostById(localPost.id);
      return feedPost ?? localPost;
    }).toList();
  }

  int get postCount => _localSearchResults.length;
  List<Topic> get topic => [...topicSuggestions];
  int get topicCount => topicSuggestions.length;

  int get page => _page;
  int get perPage => _perPage;
  bool get isLoadingPost => _isLoadingPost;
  bool get isSearching => _isSearching;
  bool get hasMorePosts => _hasMorePosts;

  bool hasUserReposted(String postId) {
    if (_postsManager?.findPostById(postId) != null) {
      return _postsManager!.hasUserReposted(postId);
    }
    return _repostedPostIds.contains(postId);
  }

  Future<void> fetchSuggestionTopics() async {
    try {
      topicSuggestions = await _topicService.fetchTopics();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> search(String? query, {bool isRefresh = false}) async {
    if (isSearching || isLoadingPost) return;

    if (isRefresh) {
      _isSearching = true;
      _page = 1;
      _hasMorePosts = true;
      _localSearchResults.clear();
    }

    if (!hasMorePosts) return;

    _isLoadingPost = true;
    notifyListeners();

    try {
      List<Post> fetched = [];
      if (query == null || query.isEmpty) {
        fetched = await _postService.fetchTrendingPosts(perPage: perPage);
      } else {
        final currentQuery = query.trim().toLowerCase();
        final keywords = currentQuery.split(RegExp(r'\s+'));

        fetched = await _postService.findPostByKeywords(
          keywords,
          page: _page,
          perPage: _perPage,
        );

        if (fetched.length < _perPage) {
          _hasMorePosts = false;
        } else {
          _page++;
        }
      }
      if (fetched.isEmpty) {
        if (isRefresh) {
          _localSearchResults = [];
        }
      } else {
        // Fetch thêm trạng thái like/repost cho các bài vừa tìm được
        final postIds = fetched.map((p) => p.id).toList();
        final likedIds = await _likeService.fetchLikedPostIds(postIds);
        // Giả sử có service fetch repost ids tương tự nếu cần

        final processedPosts = fetched
            .map((p) => p.copyWith(isLiked: likedIds.contains(p.id)))
            .toList();

        if (isRefresh) {
          _localSearchResults = processedPosts;
        } else {
          _localSearchResults.addAll(processedPosts);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (isRefresh) _isSearching = false;
      _isLoadingPost = false;
      notifyListeners();
    }
  }

  Future<void> onLikePostPressed(String id) async {
    // Kiểm tra xem bài này có trong Feed không
    final inFeed = _postsManager?.findPostById(id) != null;

    if (inFeed) {
      // nếu có trong Feed -> đưa PostsManager xử lý
      await _postsManager!.onLikePostPressed(id);
    } else {
      final index = _localSearchResults.indexWhere((p) => p.id == id);
      if (index == -1) return;

      final post = _localSearchResults[index];
      final isLiked = post.isLiked ?? false;
      final likeCount = post.likes;

      // Update UI ngay lập tức (Optimistic update)
      _localSearchResults[index] = post.copyWith(
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
        debugPrint('SearchManager like error: $e');
      }
    }
  }

  Future<void> onRepostPressed(String id) async {
    final inFeed = _postsManager?.findPostById(id) != null;
    if (inFeed) {
      await _postsManager!.onRepostPressed(id);
    } else {
      final index = _localSearchResults.indexWhere((p) => p.id == id);
      if (index == -1) return;

      final post = _localSearchResults[index];
      final isReposted = _repostedPostIds.contains(id);
      final repostCount = post.reposts;

      _localSearchResults[index] = post.copyWith(
        reposts: isReposted ? repostCount - 1 : repostCount + 1,
      );
      notifyListeners();

      try {
        if (isReposted) {
          await _repostService.unrepostPost(id);
          _repostedPostIds.remove(id);
        } else {
          await _repostService.repostPost(id);
          _repostedPostIds.add(id);

          final currentUserId = await getCurrentUserId();
          if (currentUserId != null && currentUserId != post.userId) {
            final notiId = Generate.generatePocketBaseId();

            final newNoti = notification_model.Notification(
              id: notiId,
              userId: post.userId,
              title: 'Đăng lại bài viết',
              body: 'Ai đó đã đăng lại 1 bài viết của bạn',
              type: notification_model.NotificationType.post.name,
              targetId: post.id,
              created: DateTime.now(),
              updated: DateTime.now(),
            );
            await PocketBaseNotificationService.createNotification(newNoti);
          }
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error toggling repost: $e');
      }
    }
  }
}
