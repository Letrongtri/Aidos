// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ct312h_project/utils/time_control.dart';
import 'package:flutter/material.dart';

import 'package:ct312h_project/models/post.dart';

class SinglePost extends StatelessWidget {
  const SinglePost({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "https://robohash.org/${Uri.encodeComponent(post.userId)}.png?set=set2&size=200x200",
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Trai đẹp",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(TimeControl.getTimeDifference(post.createdAt)),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_horiz),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(post.content),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite_outline),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.mode_comment_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.repeat_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
