import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:flutter/material.dart';

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
                comment.userId,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(Format.getTimeDifference(comment.createdAt)),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.content),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    label: Text(Format.getCountNumber(comment.likeCount)),
                    icon: Icon(Icons.favorite_outline),
                  ),
                  SizedBox(width: 5),
                  TextButton.icon(
                    onPressed: onReply,
                    label: Text(Format.getCountNumber(comment.relyCount)),
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
