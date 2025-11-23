import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/viewmodels/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostAction extends StatelessWidget {
  const PostAction({super.key, required this.post, this.isFromSearch = false});

  final Post post;
  final bool isFromSearch;

  @override
  Widget build(BuildContext context) {
    bool isUserReposted;
    VoidCallback onLike;
    VoidCallback onRepost;

    if (isFromSearch) {
      final searchManager = context.watch<SearchManager>();
      isUserReposted = searchManager.hasUserReposted(post.id);

      onLike = () => context.read<SearchManager>().onLikePostPressed(post.id);
      onRepost = () => context.read<SearchManager>().onRepostPressed(post.id);
    } else {
      final postsManager = context.watch<PostsManager>();
      isUserReposted = postsManager.hasUserReposted(post.id);

      onLike = () => context.read<PostsManager>().onLikePostPressed(post.id);
      onRepost = () => context.read<PostsManager>().onRepostPressed(post.id);
    }

    final isLiked = post.isLiked ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        TextButton.icon(
          onPressed: onLike,
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

        const SizedBox(width: 5),

        TextButton.icon(
          onPressed: () {
            context.pushNamed(
              AppRouteName.detailPost.name,
              pathParameters: {'id': post.id},
              extra: {'focusComment': true},
            );
          },
          style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
          label: Text(
            Format.getCountNumber(post.comments),
            style: textTheme.bodyMedium,
          ),
          icon: const Icon(Icons.mode_comment_outlined),
        ),

        const SizedBox(width: 5),

        TextButton.icon(
          onPressed: onRepost,
          style: TextButton.styleFrom(
            foregroundColor: isUserReposted
                ? colorScheme.secondary
                : colorScheme.onSurface,
          ),
          label: Text(
            Format.getCountNumber(post.reposts),
            style: textTheme.bodyMedium?.copyWith(
              color: isUserReposted
                  ? colorScheme.secondary
                  : colorScheme.onSurface,
            ),
          ),
          icon: Icon(isUserReposted ? Icons.repeat : Icons.repeat_outlined),
        ),
      ],
    );
  }
}
