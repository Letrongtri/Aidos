import 'package:ct312h_project/models/comment.dart';
// import 'package:uuid/uuid.dart';

class CommentManager {
  final List<Comment> _comments = [
    Comment(
      id: 'c001', // Uuid().v4()
      postId: "p001",
      userId: "u003",
      content: "Bài này hay quá",
      // parentId: "1",
      likeCount: 12,
      relyCount: 2,
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
      relyCount: 0,
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
      relyCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  int get commentCount {
    return _comments.length;
  }

  List<Comment> get comments {
    return [..._comments];
  }

  List<Comment> getRootComments() {
    return _comments.where((c) => c.parentId == null).toList();
  }

  List<Comment> getReplies(String parentId) {
    return _comments.where((c) => c.parentId == parentId).toList();
  }

  List<Comment> getRepliesForRoot(String rootId) {
    final allReplies = _comments
        .where((c) => c.parentId != null)
        .toList(); // Lấy toàn bộ comment reply

    // Lọc ra những reply mà "tổ tiên gốc" của nó có id == rootId
    return allReplies.where((r) {
      // lấy cha của reply r
      var parent = _comments.firstWhere(
        (c) => c.id == r.parentId,
        orElse: () => Comment.empty(),
      );

      // Leo lên cha của cha... cho đến khi không còn parentId (tức là root)
      while (parent.parentId != null) {
        parent = _comments.firstWhere(
          (c) => c.id == parent.parentId,
          orElse: () => Comment.empty(),
        );
      }

      // Nếu tổ tiên gốc có id == rootId, thì r thuộc nhánh này
      return parent.id == rootId;
    }).toList();
  }

  Comment? findById(String id) {
    return _comments.firstWhere(
      (c) => c.id == id,
      orElse: () => Comment.empty(),
    );
  }
}
