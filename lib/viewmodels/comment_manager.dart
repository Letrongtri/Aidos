import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/repository/comment_repository.dart';
import 'package:ct312h_project/viewmodels/comment_item_view_model.dart';
import 'package:ct312h_project/viewmodels/user_cache_manager.dart';
import 'package:flutter/material.dart';

class CommentManager extends ChangeNotifier {
  final CommentRepository commentRepo;
  final UserCacheManager userCache;

  CommentManager({required this.commentRepo, required this.userCache});

  List<CommentItemViewModel> _comments = [];
  final Set<String> _loadedRoots = {}; // để biết roots nào đã load replies

  bool isLoading = false;
  String? errorMessage;

  int get commentCount {
    return _comments.length;
  }

  List<CommentItemViewModel> get comments {
    return [..._comments];
  }

  // Lấy comment gốc theo bài viết
  Future<void> getRootCommentsByPostId(String postId) async {
    try {
      isLoading = true;
      notifyListeners();

      final comments = await commentRepo.fetchRootCommentsByPostId(postId);

      final userIds = comments.map((c) => c.userId).toSet().toList();
      await userCache.preloadUsers(userIds);

      final commentVMs = comments.map((c) {
        final user = userCache.tryGetCached(c.userId);
        return CommentItemViewModel.fromEntites(comment: c, user: user!);
      }).toList();

      // Chỉ thêm comment mới, tránh trùng
      for (final vm in commentVMs) {
        if (!_comments.any((c) => c.id == vm.id)) {
          _comments.add(vm);
        }
      }
    } catch (e, s) {
      debugPrint('get root comments error: $e\n$s');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy replies cho từng root comment
  Future<void> getRepliesForRoot(String rootId) async {
    if (_loadedRoots.contains(rootId)) return; // đã load rồi thì bỏ qua
    try {
      isLoading = true;
      notifyListeners();

      final replies = await commentRepo.getRepliesForRootComment(rootId);

      final userIds = replies.map((r) => r.userId).toSet().toList();
      await userCache.preloadUsers(userIds);

      final replyVMs = replies.map((r) {
        final user = userCache.tryGetCached(r.userId);
        return CommentItemViewModel.fromEntites(comment: r, user: user!);
      }).toList();

      for (final vm in replyVMs) {
        if (!_comments.any((c) => c.id == vm.id)) {
          _comments.add(vm);
        }
      }

      _loadedRoots.add(rootId);
    } catch (e, s) {
      debugPrint('getRepliesForRoot error: $e\n$s');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Comment root (parentId == null)
  List<CommentItemViewModel> getRootCommentsByPostIdLocal(String id) {
    return _comments
        .where((c) => c.parentId == null && c.postId == id)
        .toList();
  }

  // Comment reply của một root (kể cả reply lồng nhau)
  List<CommentItemViewModel> getRepliesForRootLocal(String rootId) {
    final allReplies = _comments.where((c) => c.parentId != null).toList();
    return allReplies.where((r) {
      var parent = _comments.firstWhere(
        (c) => c.id == r.parentId,
        orElse: () => CommentItemViewModel.empty(),
      );
      while (parent.parentId != null) {
        parent = _comments.firstWhere(
          (c) => c.id == parent.parentId,
          orElse: () => CommentItemViewModel.empty(),
        );
      }
      return parent.id == rootId;
    }).toList();
  }

  CommentItemViewModel? findCommentByIdLocal(String id) {
    return _comments.firstWhere(
      (c) => c.id == id,
      orElse: () => CommentItemViewModel.empty(),
    );
  }

  Future<void> fetchCommentsByPostId(String postId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final comments = await commentRepo.fetchCommentsByPostId(postId);

      // Lấy danh sách userId duy nhất từ các comments
      final userIds = comments.map((c) => c.userId).toSet().toList();
      await userCache.preloadUsers(userIds);

      // Gộp lại: comment + username
      _comments = comments.map((comment) {
        final user = userCache.tryGetCached(comment.userId);
        if (user == null) {
          throw Exception(
            "Comment ${comment.id}: Missing user ${comment.userId} in cache",
          );
        }

        return CommentItemViewModel.fromEntites(comment: comment, user: user);
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String text,
    required String postId,
    required String currentUserId,
    String? parentId,
  }) async {
    try {
      final newComment = Comment(
        id: UniqueKey().toString(),
        postId: postId,
        userId: currentUserId,
        content: text,
        parentId: parentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        replyCount: 0,
      );
      await commentRepo.addComment(newComment);

      final user = userCache.tryGetCached(currentUserId);
      final vm = CommentItemViewModel.fromEntites(
        comment: newComment,
        user: user!,
      );
      _comments.insert(0, vm);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> onLikeCommentPressed(String id) async {
    final index = _comments.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final comment = _comments[index];

    try {
      final currentLiked = comment.isLiked;
      final updatedLikeCount = currentLiked
          ? comment.likeCount - 1
          : comment.likeCount + 1;

      _comments[index] = comment.copyWith(
        likeCount: updatedLikeCount,
        isLiked: !currentLiked,
      );
      notifyListeners();

      // TODO: gọi repo để cập nhật dữ liệu
      // if (currentLiked) {
      //   await commentRepo.unlikePost(id);
      // } else {
      //   await commentRepo.likePost(id);
      // }
    } catch (e) {
      errorMessage = e.toString();
      _comments[index] = comment; // rollback
      notifyListeners();
    }
  }
}
