// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostAction extends StatelessWidget {
  const PostAction({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () {
            context.read<PostsManager>().onLikePostPressed(post.id);
          },
          label: Text(Format.getCountNumber(post.likes)),
          icon: Icon(
            post.isLiked ?? false ? Icons.favorite : Icons.favorite_outline,
            color: (post.isLiked != null && post.isLiked!)
                ? Colors.red
                : Colors.white,
          ),
        ),
        SizedBox(width: 5),
        TextButton.icon(
          onPressed: () {
            context.goNamed(
              'detail',
              pathParameters: {'id': post.id},
              extra: {'focusComment': true},
            );
          },
          label: Text(Format.getCountNumber(post.comments)),
          icon: Icon(Icons.mode_comment_outlined),
        ),
        SizedBox(width: 5),
        TextButton.icon(
          onPressed: () {},
          label: Text(Format.getCountNumber(post.reposts)),
          icon: Icon(Icons.repeat_outlined),
        ),
      ],
    );
  }
}
