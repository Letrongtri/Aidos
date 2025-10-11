import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/comment_item_view_model.dart';
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

  final CommentItemViewModel comment;
  final VoidCallback? onReply;
  final String? replyingToUser;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingToUser != null)
            Text(
              "Reply to @$replyingToUser",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          Row(
            children: [
              Text(
                comment.username,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(Format.getTimeDifference(comment.createdAt)),
              IconButton(
                onPressed: () {
                  showPostActionsBottomSheet(context, onUpdate: () {});
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
                        comment.id,
                      );
                    },
                    label: Text(Format.getCountNumber(comment.likeCount)),
                    icon: Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: comment.isLiked ? Colors.red : Colors.white,
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
}
