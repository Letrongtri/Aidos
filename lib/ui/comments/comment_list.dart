import 'package:comment_tree/comment_tree.dart' hide Comment;
import 'package:ct312h_project/ui/comments/comment_item.dart';
import 'package:ct312h_project/viewmodels/comment_item_view_model.dart';
import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';

class CommentList extends StatefulWidget {
  const CommentList({
    super.key,
    required this.comments,
    required this.onReply,
    required this.postId,
  });

  final CommentManager comments;
  final Function(CommentItemViewModel) onReply;
  final String postId;

  @override
  State<CommentList> createState() => _CommentListState();
}

enum CommentBranchState { collapsed, expanded, loading }

class _CommentListState extends State<CommentList> {
  final Map<String, CommentBranchState> _branchState = {};

  @override
  void initState() {
    super.initState();
    // Load root comments khi widget khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.comments.getRootCommentsByPostId(widget.postId);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rootComments = widget.comments.getRootCommentsByPostIdLocal(
      widget.postId,
    );

    return Column(
      children: rootComments.map((root) {
        final replies = widget.comments.getRepliesForRootLocal(root.id);
        final state = _branchState[root.id] ?? CommentBranchState.collapsed;

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentTreeWidget(
                root,
                state == CommentBranchState.collapsed ? [] : replies,
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
                  onReply: () => widget.onReply(data),
                  isRoot: true,
                ),

                contentChild: (context, data) {
                  final parent = widget.comments.findCommentByIdLocal(
                    data.parentId ?? '',
                  );
                  return CommentItem(
                    comment: data,
                    onReply: () => widget.onReply(data),
                    replyingToUser: parent?.userId,
                    isRoot: false,
                  );
                },
              ),

              if (root.replyCount > 0)
                if (state == CommentBranchState.loading)
                  Center(child: CircularProgressIndicator())
                else
                  TextButton.icon(
                    onPressed: () async {
                      // nếu replies đang mở
                      if (state == CommentBranchState.expanded) {
                        setState(
                          () => _branchState[root.id] =
                              CommentBranchState.collapsed,
                        );
                      } else if (state == CommentBranchState.collapsed) {
                        // nếu replies đang đóng
                        setState(
                          () => _branchState[root.id] =
                              CommentBranchState.loading,
                        );

                        await widget.comments.getRepliesForRoot(root.id);

                        setState(
                          () => _branchState[root.id] =
                              CommentBranchState.expanded,
                        );
                      }
                    },

                    icon: Icon(
                      state == CommentBranchState.collapsed
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up,
                    ),
                    label: Text(
                      state == CommentBranchState.collapsed
                          ? "Show ${root.replyCount}"
                          : "Hide",
                    ),
                  ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
