import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLiked = comment.isLiked ?? false;
    final manager = context.watch<CommentManager>();
    final currentUser = context.read<AuthManager>().user;
    final replyingToUserName = comment.user?.id == currentUser?.id
        ? currentUser?.username
        : replyingToUser;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      Text(
                        comment.user?.username ??
                            Generate.generateUsername(comment.userId),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                      if (replyingToUser != null)
                        Row(
                          children: [
                            const Icon(Icons.chevron_right),
                            Text(
                              '$replyingToUserName',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Format.getTimeDifference(comment.created),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (currentUser?.id == comment.user?.id)
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
                        _showDeleteConfirmation(context, manager, comment.id!);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.more_horiz,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.content, style: textTheme.bodyMedium),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<CommentManager>().onLikeCommentPressed(
                        comment.id!,
                        comment.likesCount,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: isLiked
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    label: Text(
                      Format.getCountNumber(comment.likesCount),
                      style: textTheme.bodySmall?.copyWith(
                        color: isLiked
                            ? colorScheme.error
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_outline,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onReply,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    label: Text(
                      Format.getCountNumber(comment.replyCount),
                      style: textTheme.bodySmall,
                    ),
                    icon: const Icon(Icons.mode_comment_outlined, size: 18),
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

    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        title: const Text(
          "Edit comment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            hintText: "Enter your comment",
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white38),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            hintStyle: const TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;

              try {
                await manager.updateComment(comment.id!, value);

                if (context.mounted) Navigator.pop(context);

                messenger.showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Comment updated successfully!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error updating comment: $e',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CommentManager manager,
    String commentId,
  ) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        title: const Text(
          "Delete Comment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this comment?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await manager.deleteComment(commentId);

        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              'Comment deleted successfully!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting comment: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }
}
