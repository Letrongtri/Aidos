// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  post.user?.username ?? Generate.generateUsername(post.userId),

                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[300],
                  ),
                ),

                if (post.topic != null)
                  Row(
                    children: [
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          context.goNamed(
                            AppRouteName.search.name,
                            queryParameters: {'q': post.topic!.name},
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          post.topic!.name,

                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        Text(
          Format.getTimeDifference(post.created),

          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        IconButton(
          onPressed: () {
            showPostActionsBottomSheet(
              context,
              onUpdate: () {
                Navigator.pop(context);
                context.pushNamed(AppRouteName.post.name, extra: post);
              },
              onDelete: () async {
                Navigator.pop(context);

                final postsManager = context.read<PostsManager>();

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    title: Text('Delete Post', style: textTheme.titleLarge),
                    content: Text(
                      'Are you sure you want to delete this post?',
                      style: textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Delete',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await postsManager.deletePost(post.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Post deleted successfully',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          backgroundColor: colorScheme.secondary,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting post: $e')),
                      );
                    }
                  }
                }
              },
            );
          },
          icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
