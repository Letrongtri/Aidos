import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/detail_post_manager.dart';
import 'package:ct312h_project/viewmodels/post_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPostContent extends StatelessWidget {
  const DetailPostContent({super.key, required this.post});
  final PostItemViewModel post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(userId: post.userId, size: 25),
            SizedBox(width: 8),
            Text(post.username, style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Text(
              Format.getTimeDifference(post.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(post.content),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                context.read<DetailPostManager>().onLikePostPressed(post.id);
              },
              label: Text(Format.getCountNumber(post.likeCount)),
              icon: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_outline,
                color: post.isLiked ? Colors.red : Colors.white,
              ),
            ),
            SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {},
              label: Text(Format.getCountNumber(post.commentCount)),
              icon: Icon(Icons.mode_comment_outlined),
            ),
            SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {},
              label: Text(Format.getCountNumber(post.repostCount)),
              icon: Icon(Icons.repeat_outlined),
            ),
          ],
        ),
        Divider(height: 20, color: Colors.grey),
      ],
    );
  }
}
