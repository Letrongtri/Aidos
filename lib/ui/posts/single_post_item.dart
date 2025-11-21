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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () {
        context.goNamed(
          AppRouteName.detailPost.name,
          pathParameters: {'id': post.id},
        );
      },

      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(userId: post.userId, size: 45),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostHeader(post: post),

                      const SizedBox(height: 4),

                      Text(post.content, style: textTheme.bodyLarge),

                      const SizedBox(height: 8),

                      PostAction(post: post),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.12)),
          ],
        ),
      ),
    );
  }
}
