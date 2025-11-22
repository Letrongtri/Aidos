import 'package:comment_tree/comment_tree.dart' hide Comment;
import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/ui/comments/comment_item.dart';
import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentList extends StatefulWidget {
  const CommentList({super.key, required this.onReply, required this.postId});

  final Function(Comment) onReply;
  final String postId;

  @override
  State<CommentList> createState() => _CommentListState();
}

enum CommentBranchState { collapsed, expanded, loading }

class _CommentListState extends State<CommentList> {
  final Map<String, CommentBranchState> _branchState = {};
  late Future<void> _fetchComments;

  @override
  void initState() {
    super.initState();
    _fetchComments = context.read<CommentManager>().getRootCommentsByPostId();
  }

  @override
  Widget build(BuildContext context) {
    final commentManager = context.watch<CommentManager>();

    // Lấy Theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder(
      future: _fetchComments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Lỗi tải bình luận",
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final rootComments = commentManager.getRootCommentsByPostIdLocal();

        if (rootComments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Chưa có bình luận nào.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }

        return Column(
          children: rootComments.map((root) {
            final replies = commentManager.getRepliesForRootLocal(root.id!);
            final state = _branchState[root.id] ?? CommentBranchState.collapsed;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentTreeWidget(
                    root,
                    state == CommentBranchState.collapsed ? [] : replies,
                    treeThemeData: TreeThemeData(
                      lineColor: colorScheme.onSurface.withOpacity(0.12),
                      lineWidth: 1,
                    ),

                    avatarRoot: (context, data) => PreferredSize(
                      preferredSize: Size.fromRadius(25),
                      child: Avatar(userId: data.userId, size: 30),
                    ),
                    avatarChild: (context, data) => PreferredSize(
                      preferredSize: Size.fromRadius(20),
                      child: Avatar(userId: data.userId, size: 30),
                    ),

                    contentRoot: (context, data) => CommentItem(
                      comment: data,
                      onReply: () => widget.onReply(data),
                      isRoot: true,
                    ),

                    contentChild: (context, data) {
                      final parent = commentManager.findCommentByIdLocal(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: state == CommentBranchState.loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.secondary,
                              ),
                            )
                          : TextButton.icon(
                              onPressed: () async {
                                if (state == CommentBranchState.expanded) {
                                  setState(
                                    () => _branchState[root.id!] =
                                        CommentBranchState.collapsed,
                                  );
                                } else if (state ==
                                    CommentBranchState.collapsed) {
                                  setState(
                                    () => _branchState[root.id!] =
                                        CommentBranchState.loading,
                                  );

                                  try {
                                    await context
                                        .read<CommentManager>()
                                        .getRepliesForRoot(root.id!);

                                    if (context.mounted) {
                                      setState(
                                        () => _branchState[root.id!] =
                                            CommentBranchState.expanded,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(
                                        () => _branchState[root.id!] =
                                            CommentBranchState.collapsed,
                                      );
                                    }
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),

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
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
