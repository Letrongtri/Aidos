// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/posts/post_action.dart';
import 'package:ct312h_project/ui/posts/post_header.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class SinglePostItem extends StatelessWidget {
  const SinglePostItem({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRouteName.detailPost.name,
          pathParameters: {'id': post.id},
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(userId: post.userId, size: 45),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                PostHeader(post: post),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.content),
                    PostAction(post: post),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
