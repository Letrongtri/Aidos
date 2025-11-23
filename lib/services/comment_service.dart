import 'dart:async';

import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class CommentService {
  Future<Comment?> addComment(
    Comment comment,
    int postCommentCount,
    Comment? parentComment,
  ) async {
    try {
      final pb = await getPocketbaseInstance();
      final model = pb.authStore.record;

      if (model == null) return null;

      final user = User.fromMap(model.toJson());

      final userId = user.id;

      final data = {...comment.toPocketBase(), 'userId': userId};

      final commentModel = await pb.collection('comments').create(body: data);

      return comment.copyWith(id: commentModel.id, userId: userId, user: user);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception();
    }
  }

  Future<List<Comment>> fetchRootCommentsByPostId({
    required String postId,
    int page = 1,
    int perPage = 10,
  }) async {
    List<Comment> comments = [];
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId';

      final filter = 'postId="$postId" && (parentId="" || parentId=null)';

      final result = await pb
          .collection('comments')
          .getList(
            page: page,
            perPage: perPage,
            filter: filter,
            expand: expandFields,
            sort: '-replyCount,-likesCount,-created',
          );

      comments = result.items.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        return Comment.fromPocketbase(record: record, userRecord: user);
      }).toList();

      return comments;
    } catch (e) {
      return comments;
    }
  }

  Future<List<Comment>> getRepliesForRootComment(String rootId) async {
    List<Comment> replies = [];
    try {
      final pb = await getPocketbaseInstance();
      const expandFields = 'userId';

      // Filter các comment có parentId = rootId
      final filter = 'rootId="$rootId"';

      final result = await pb
          .collection('comments')
          .getFullList(
            filter: filter,
            expand: expandFields,
            sort: '-replyCount,-likesCount,-created', // mới nhất trước
          );

      replies = result.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        return Comment.fromPocketbase(record: record, userRecord: user);
      }).toList();

      return replies;
    } catch (e, st) {
      debugPrint('Error fetching replies for comment $rootId: $e\n$st');
      return replies;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final pb = await getPocketbaseInstance();

      await pb.collection('comments').delete(commentId);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb
          .collection('comments')
          .update(commentId, body: {'content': content});
    } catch (e) {
      debugPrint(e.toString());
      throw Exception();
    }
  }

  Stream<RecordSubscriptionEvent> subscribeToComment() {
    // Tạo controller
    final controller = StreamController<RecordSubscriptionEvent>();

    // Biến để lưu hàm unsubscribe
    UnsubscribeFunc? unsubscribeFunc;

    // Bắt đầu logic khởi tạo bất đồng bộ
    getPocketbaseInstance().then((pb) {
      pb
          .collection('comments')
          .subscribe('*', (e) {
            if (!controller.isClosed) {
              controller.add(e);
            }
          })
          .then((func) {
            unsubscribeFunc = func;
          })
          .catchError((err) {
            if (!controller.isClosed) controller.addError(err);
          });
    });

    // Dọn dẹp khi không lắng nghe nữa
    controller.onCancel = () async {
      if (unsubscribeFunc != null) {
        await unsubscribeFunc!();
      }
      await controller.close();
    };

    return controller.stream;
  }
}
