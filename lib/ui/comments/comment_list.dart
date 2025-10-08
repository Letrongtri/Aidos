import 'package:comment_tree/comment_tree.dart' hide Comment;
import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/ui/comments/comment_item.dart';
import 'package:ct312h_project/ui/comments/comment_manager.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  CommentList({super.key, required this.comments, required this.onReply});

  final CommentManager comments;
  final Function(Comment) onReply;

  late final rootComments = comments.getRootComments();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rootComments.map((root) {
        final replies = comments.getRepliesForRoot(root.id);

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CommentTreeWidget(
            root,
            replies,
            treeThemeData: TreeThemeData(
              lineColor: Colors.grey.shade400,
              lineWidth: 1,
            ),

            avatarRoot: (context, data) => PreferredSize(
              preferredSize: Size.fromRadius(25),
              child: Avatar(userId: data.userId),
            ),
            avatarChild: (context, data) => PreferredSize(
              preferredSize: Size.fromRadius(20),
              child: Avatar(userId: data.userId, size: 40),
            ),

            contentRoot: (context, data) => CommentItem(
              comment: data,
              onReply: () => onReply(data),
              isRoot: true,
            ),

            contentChild: (context, data) {
              final parent = comments.findById(data.parentId ?? '');
              return CommentItem(
                comment: data,
                onReply: () => onReply(data),
                replyingToUser: parent?.userId,
                isRoot: false,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
