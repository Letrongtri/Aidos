import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class CommentService {
  // Future<List<Comment>> fetchCommentsByPostId(String postId) async {
  //   // TODO: fetch dữ liệu thật
  //   await Future.delayed(Duration(milliseconds: 300));

  //   return [
  //     // Comment(
  //     //   id: 'c001', // Uuid().v4()
  //     //   postId: "p001",
  //     //   userId: "u003",
  //     //   content: "Bài này hay quá",
  //     //   // parentId: "1",
  //     //   likeCount: 12,
  //     //   replyCount: 2,
  //     //   createdAt: DateTime.now().subtract(const Duration(days: 3)),
  //     //   updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
  //     // ),
  //     // Comment(
  //     //   id: 'c002',
  //     //   postId: "p001",
  //     //   userId: "u002",
  //     //   content: "Ok luôn <33",
  //     //   parentId: "c001",
  //     //   likeCount: 1,
  //     //   replyCount: 0,
  //     //   createdAt: DateTime.now().subtract(const Duration(days: 2)),
  //     //   updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  //     // ),
  //     // Comment(
  //     //   id: 'c003',
  //     //   postId: "p001",
  //     //   userId: "u004",
  //     //   content: "Tuyệt vời quá",
  //     //   parentId: "c002",
  //     //   likeCount: 0,
  //     //   replyCount: 0,
  //     //   createdAt: DateTime.now().subtract(const Duration(days: 1)),
  //     //   updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
  //     // ),
  //   ];
  // }

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

      if (parentComment != null && comment.parentId!.isNotEmpty) {
        await pb
            .collection('comments')
            .update(
              parentComment.id!,
              body: {'replyCount': parentComment.replyCount + 1},
            );
      }

      await pb
          .collection('posts')
          .update(comment.postId, body: {'comments': postCommentCount + 1});

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
      final filter = 'parentId="$rootId"';

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
      print('Error fetching replies for comment $rootId: $e\n$st');
      return replies;
    }
  }

  Future<List<Comment>> getAllRepliesRecursively(
    String rootId, {
    int depth = 20,
  }) async {
    if (depth > 10) return [];
    final replies = await getRepliesForRootComment(rootId);
    List<Comment> allReplies = [...replies];

    for (final reply in replies) {
      final subReplies = await getAllRepliesRecursively(
        reply.id!,
        depth: depth + 1,
      );
      allReplies.addAll(subReplies);
    }

    return allReplies;
  }

  // List<CommentItemViewModel> getRepliesForRoot(String rootId) {
  //   final allReplies = _comments
  //       .where((c) => c.parentId != null)
  //       .toList(); // Lấy toàn bộ comment reply

  //   // Lọc ra những reply mà "tổ tiên gốc" của nó có id == rootId
  //   return allReplies.where((r) {
  //     // lấy cha của reply r
  //     var parent = _comments.firstWhere(
  //       (c) => c.id == r.parentId,
  //       orElse: () => CommentItemViewModel.empty(),
  //     );

  //     // Leo lên cha của cha... cho đến khi không còn parentId (tức là root)
  //     while (parent.parentId != null) {
  //       parent = _comments.firstWhere(
  //         (c) => c.id == parent.parentId,
  //         orElse: () => CommentItemViewModel.empty(),
  //       );
  //     }

  //     // Nếu tổ tiên gốc có id == rootId, thì r thuộc nhánh này
  //     return parent.id == rootId;
  //   }).toList();
  // }
}
