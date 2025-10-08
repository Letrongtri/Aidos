import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:flutter/material.dart';

class DetailPostContent extends StatelessWidget {
  const DetailPostContent({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "https://robohash.org/${Uri.encodeComponent(post.userId)}.png?set=set2&size=150x150",
              ),
            ),
            SizedBox(width: 8),
            Text("traidepvct", style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: () {},
              label: Text(Format.getCountNumber(post.likeCount)),
              icon: Icon(Icons.favorite_outline),
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
