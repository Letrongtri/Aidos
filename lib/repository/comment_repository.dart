import 'package:ct312h_project/models/comment.dart';
import 'package:flutter/widgets.dart';

class CommentRepository {
  Future<List<Comment>> fetchCommentsByPostId(String postId) async {
    // TODO: fetch dữ liệu thật
    await Future.delayed(Duration(milliseconds: 300));

    return [
      Comment(
        id: 'c001', // Uuid().v4()
        postId: "p001",
        userId: "u003",
        content: "Bài này hay quá",
        // parentId: "1",
        likeCount: 12,
        replyCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Comment(
        id: 'c002',
        postId: "p001",
        userId: "u002",
        content: "Ok luôn <33",
        parentId: "c001",
        likeCount: 1,
        replyCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: 'c003',
        postId: "p001",
        userId: "u004",
        content: "Tuyệt vời quá",
        parentId: "c002",
        likeCount: 0,
        replyCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<void> addComment(Comment comment) async {
    // TODO: thêm add comment logic
  }

  Future<List<Comment>> fetchRootCommentsByPostId(String postId) async {
    // TODO: fetch dữ liệu thật
    // Lấy dữ liệu mà parentId = null
    await Future.delayed(Duration(milliseconds: 300));

    return [
      Comment(
        id: 'c001', // Uuid().v4()
        postId: "p001",
        userId: "u003",
        content: "Bài này hay quá",
        // parentId: "1",
        likeCount: 12,
        replyCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  Future<List<Comment>> getRepliesForRootComment(String rootId) async {
    try {
      // TODO: Thêm logic lấy replies
      return [
        Comment(
          id: 'c002',
          postId: "p001",
          userId: "u002",
          content: "Ok luôn <33",
          parentId: "c001",
          likeCount: 1,
          replyCount: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Comment(
          id: 'c003',
          postId: "p001",
          userId: "u004",
          content: "Tuyệt vời quá",
          parentId: "c002",
          likeCount: 0,
          replyCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];
    } catch (e, s) {
      debugPrint('getRepliesForRoot error: $e\n$s');
      rethrow;
    }
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
