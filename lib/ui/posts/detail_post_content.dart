import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DetailPostContent extends StatelessWidget {
  const DetailPostContent({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final postsManager = context.watch<PostsManager>();
    final isReposted = postsManager.hasUserReposted(post.id);
    final isLiked = post.isLiked ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(userId: post.userId, size: 40),
            SizedBox(width: 8),
            Text(
              post.user?.username ?? Generate.generateUsername(post.userId),

              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
            const Spacer(),
            Text(
              Format.getTimeDifference(post.created),

              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Text(post.content, style: textTheme.bodyLarge),

        const SizedBox(height: 4),

        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onLikePostPressed(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isLiked
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.likes),
                style: textTheme.bodyMedium?.copyWith(
                  color: isLiked ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_outline),
            ),

            const SizedBox(width: 4),

            TextButton.icon(
              onPressed: () {
                context.pushNamed(
                  AppRouteName.detailPost.name,
                  pathParameters: {'id': post.id},
                  extra: {'focusComment': true},
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.comments),
                style: textTheme.bodyMedium,
              ),
              icon: const Icon(Icons.mode_comment_outlined),
            ),

            const SizedBox(width: 4),

            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onRepostPressed(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isReposted
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.reposts),
                style: textTheme.bodyMedium?.copyWith(
                  color: isReposted ? Colors.white : colorScheme.onSurface,
                ),
              ),
              icon: Icon(isReposted ? Icons.repeat : Icons.repeat_outlined),
            ),
          ],
        ),

        Divider(height: 20, color: colorScheme.onSurface.withOpacity(0.12)),
      ],
    );
  }
}
