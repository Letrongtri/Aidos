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
    // Lấy Theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isLiked = comment.isLiked ?? false;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingToUser != null)
            Text(
              "Reply to @$replyingToUser",
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),

          Row(
            children: [
              Text(
                comment.user?.username ??
                    Generate.generateUsername(comment.userId),

                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
              const Spacer(),
              Text(
                Format.getTimeDifference(comment.created),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              IconButton(
                onPressed: () {
                  showPostActionsBottomSheet(context, onUpdate: () {});
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
}
