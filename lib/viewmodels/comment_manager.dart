// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ct312h_project/models/notification.dart' as notification_model;
import 'package:ct312h_project/services/services.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';

import 'package:ct312h_project/models/comment.dart';

class CommentManager extends ChangeNotifier {
  CommentManager({required this.postId});
  final String postId;

  AuthManager? _authManager;

  final _commentService = CommentService();
  final _likeService = LikeService();

  final List<Comment> _comments = [];
  final Set<String> _loadedRoots = {}; // để biết roots nào đã load replies

  String? errorMessage;

  int get commentCount {
    return _comments.length;
  }

  List<Comment> get comments {
    return [..._comments];
  }

  void updateAuthUser(AuthManager auth) {
    _authManager = auth;

    if (auth.user != null) {
      for (int i = 0; i < _comments.length; i++) {
        final comment = _comments[i];
        if (comment.userId == auth.user!.id) {
          _comments[i] = comment.copyWith(user: auth.user);
        }
      }
    }
    notifyListeners();
  }

  // Lấy comment gốc theo bài viết
  Future<void> getRootCommentsByPostId() async {
    try {
      final fetchedComments = await _commentService.fetchRootCommentsByPostId(
        postId: postId,
      );

      List<Comment> comments = [];
      List<String> commentIds = [];
      // Chỉ thêm comment mới, tránh trùng
      for (final cmt in fetchedComments) {
        if (!_comments.any((c) => c.id == cmt.id)) {
          comments.add(cmt);
          commentIds.add(cmt.id!);
        }
      }

      final likedCommentIds = await _likeService.fetchLikedCommentIds(
        commentIds,
      );

      if (likedCommentIds.isNotEmpty) {
        comments = comments
            .map((c) => c.copyWith(isLiked: likedCommentIds.contains(c.id)))
            .toList();
      }

      _comments.addAll(comments);
    } catch (e, s) {
      debugPrint('get root comments error: $e\n$s');
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Lấy replies cho từng root comment
  Future<void> getRepliesForRoot(String rootId) async {
    if (_loadedRoots.contains(rootId)) return; // đã load rồi thì bỏ qua
    try {
      final replies = await _commentService.getRepliesForRootComment(rootId);

      List<Comment> comments = [];
      List<String> commentIds = [];

      for (final cmt in replies) {
        if (!_comments.any((c) => c.id == cmt.id)) {
          comments.add(cmt);
          commentIds.add(cmt.id!);
        }
      }

      final likedCommentIds = await _likeService.fetchLikedCommentIds(
        commentIds,
      );

      if (likedCommentIds.isNotEmpty) {
        comments = comments
            .map((c) => c.copyWith(isLiked: likedCommentIds.contains(c.id)))
            .toList();
      }

      _comments.addAll(comments);

      _loadedRoots.add(rootId);
    } catch (e, s) {
      debugPrint('getRepliesForRoot error: $e\n$s');
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Comment root (parentId == null)
  List<Comment> getRootCommentsByPostIdLocal() {
    return _comments
        .where(
          (c) =>
              (c.parentId == null || c.parentId!.isEmpty) && c.postId == postId,
        )
        .toList();
  }

  // Comment reply của một root (kể cả reply lồng nhau)
  List<Comment> getRepliesForRootLocal(String rootId) {
    return _comments.where((c) {
      if (c.parentId == null || c.parentId!.isEmpty) return false;
      if (c.rootId == rootId) return true;
      return false;
    }).toList();
  }

  Comment? findCommentByIdLocal(String id) {
    return _comments.firstWhere(
      (c) => c.id == id,
      orElse: () => Comment.empty(),
    );
  }

  Future<void> addComment({
    required String text,
    required String ownerId,
    int postCommentCount = 0,
    Comment? parentComment,
  }) async {
    final currentUserId = _authManager?.user?.id;

    if (currentUserId == null) return;

    try {
      final newComment = Comment(
        postId: postId,
        userId: '',
        content: text,
        parentId: parentComment?.id,
        rootId: parentComment?.rootId,
        created: DateTime.now(),
        updated: DateTime.now(),
        likesCount: 0,
        replyCount: 0,
      );

      final comment = await _commentService.addComment(
        newComment,
        postCommentCount,
        parentComment,
      );

      if (comment == null) {
        throw Exception("Cannot add your comment");
      }

      if (parentComment != null && comment.parentId!.isNotEmpty) {
        final newCount = parentComment.replyCount + 1;

        final index = _comments.indexWhere((c) => c.id == parentComment.id);
        if (index != -1) {
          _comments[index] = parentComment.copyWith(relyCount: newCount);
        }
      }

      _comments.insert(0, comment);
      notifyListeners();

      final notiId = Generate.generatePocketBaseId();
      notification_model.Notification? newNoti;

      if (parentComment != null && parentComment.userId != currentUserId) {
        newNoti = notification_model.Notification(
          id: notiId,
          userId: parentComment.userId,
          title: 'Trả lời bình luận',
          body: 'Ai đó đã trả lời bình luận của bạn',
          type: notification_model.NotificationType.reply.name,
          targetId: parentComment.postId,
          created: DateTime.now(),
          updated: DateTime.now(),
        );
      } else if (parentComment == null && ownerId != currentUserId) {
        newNoti = notification_model.Notification(
          id: notiId,
          userId: ownerId,
          title: 'Bình luận mới',
          body: 'Ai đó đã bình luận bài viết của bạn',
          type: notification_model.NotificationType.like.name,
          targetId: postId,
          created: DateTime.now(),
          updated: DateTime.now(),
        );
      }
      if (newNoti != null) {
        await PocketBaseNotificationService.createNotification(newNoti);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> onLikeCommentPressed(
    String commentId,
    int currentLikeCount,
  ) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;
    final comment = _comments[index];

    final currentUserId = _authManager?.user?.id;
    if (currentUserId == null) return;

    try {
      final currentLiked = comment.isLiked ?? false;
      final updatedLikeCount = currentLiked
          ? comment.likesCount - 1
          : comment.likesCount + 1;

      _comments[index] = comment.copyWith(
        likesCount: updatedLikeCount,
        isLiked: !currentLiked,
      );
      notifyListeners();

      if (currentLiked) {
        await _likeService.unlikeComment(commentId, currentLikeCount);
      } else {
        await _likeService.likeComment(commentId, currentLikeCount);

        if (currentUserId != comment.userId) {
          final notiId = Generate.generatePocketBaseId();

          final newNoti = notification_model.Notification(
            id: notiId,
            userId: comment.userId,
            title: 'Yêu thích bình luận',
            body: 'Ai đó đã yêu thích bình luận của bạn',
            type: notification_model.NotificationType.like.name,
            targetId: comment.postId,
            created: DateTime.now(),
            updated: DateTime.now(),
          );
          await PocketBaseNotificationService.createNotification(newNoti);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      _comments[index] = comment; // rollback
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = _comments[index];

    try {
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();

      await _commentService.deleteComment(commentId);
    } catch (e) {
      // rollback
      _comments.insert(index, comment);
      notifyListeners();
      debugPrint("deleteComment error: $e");
      rethrow;
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = _comments[index];
    try {
      _comments[index] = _comments[index].copyWith(content: content);
      notifyListeners();

      await _commentService.updateComment(commentId, content);
    } catch (e) {
      // rollback
      _comments[index] = comment;
      notifyListeners();
      debugPrint("updateComment error: $e");
      rethrow;
    }
  }
}
