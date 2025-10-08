// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ct312h_project/screens/detail_post_screen.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:flutter/material.dart';

import 'package:ct312h_project/models/post.dart';

class SinglePostItem extends StatelessWidget {
  const SinglePostItem({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => DetailPostScreen(post: post)),
        );
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(userId: post.userId, size: 45),
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
                        Text(Format.getTimeDifference(post.createdAt)),
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
                            TextButton.icon(
                              onPressed: () {},
                              label: Text(
                                Format.getCountNumber(post.likeCount),
                              ),
                              icon: Icon(Icons.favorite_outline),
                            ),
                            SizedBox(width: 5),
                            TextButton.icon(
                              onPressed: () {},
                              label: Text(
                                Format.getCountNumber(post.commentCount),
                              ),
                              icon: Icon(Icons.mode_comment_outlined),
                            ),
                            SizedBox(width: 5),
                            TextButton.icon(
                              onPressed: () {},
                              label: Text(
                                Format.getCountNumber(post.repostCount),
                              ),
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
      ),
    );
  }
}
