import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.replyingToUser,
    this.isRoot = false,
  });

  final Comment comment;
  final VoidCallback? onReply;
  final String? replyingToUser;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CommentManager>();

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      Text(
                        comment.user?.username ??
                            Generate.generateUsername(comment.userId),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (replyingToUser != null)
                        Row(
                          children: [
                            Icon(Icons.chevron_right),
                            Text(
                              "$replyingToUser",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(Format.getTimeDifference(comment.created)),
              IconButton(
                onPressed: () {
                  showPostActionsBottomSheet(
                    context,
                    onUpdate: () {
                      Navigator.pop(context);
                      _showEditCommentDialog(context, manager, comment);
                    },
                    onDelete: () {
                      Navigator.pop(context);
                      context.read<CommentManager>().deleteComment(comment.id!);
                    },
                  );
                },
                icon: Icon(Icons.more_horiz),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.content),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<CommentManager>().onLikeCommentPressed(
                        comment.id!,
                        comment.likesCount,
                      );
                    },
                    label: Text(Format.getCountNumber(comment.likesCount)),
                    icon: Icon(
                      comment.isLiked ?? false
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: comment.isLiked ?? false
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  TextButton.icon(
                    onPressed: onReply,
                    label: Text(Format.getCountNumber(comment.replyCount)),
                    icon: Icon(Icons.mode_comment_outlined),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCommentDialog(
    BuildContext context,
    CommentManager manager,
    Comment comment,
  ) async {
    final theme = Theme.of(context);
    final controller = TextEditingController();

    controller.text = comment.content;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        title: const Text("Edit comment"),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            hintText: "Enter your comment",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text;

              manager.updateComment(comment.id!, value);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
