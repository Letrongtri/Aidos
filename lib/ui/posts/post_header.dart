// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  post.user?.username ?? generateUsername(post.userId),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (post.topic != null)
                  Row(
                    children: [
                      Icon(Icons.chevron_right),
                      TextButton(
                        onPressed: () {
                          context.goNamed(
                            'search',
                            queryParameters: {'q': post.topic!.name},
                          );
                        },
                        child: Text(
                          post.topic!.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(Format.getTimeDifference(post.created)),
        IconButton(
          onPressed: () {
            showPostActionsBottomSheet(context, onUpdate: () {});
          },
          icon: Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
