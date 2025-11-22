// lib/ui/user/profile_replies_list.dart
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:flutter/material.dart';

class ProfileRepliesList extends StatelessWidget {
  final List<Map<String, dynamic>> repliedPosts;
  final bool isLoading;

  const ProfileRepliesList({
    super.key,
    required this.repliedPosts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.secondary),
      );
    }

    if (repliedPosts.isEmpty) {
      return Center(child: Text('No replies yet', style: textTheme.bodyMedium));
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),

      separatorBuilder: (_, __) =>
          Divider(color: colorScheme.onSurface.withOpacity(0.2)),
      itemCount: repliedPosts.length,
      itemBuilder: (context, index) {
        final post = repliedPosts[index]['post'] as Post;
        final comment = repliedPosts[index]['comment'] as String;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SinglePostItem(post: post),
              Container(
                margin: const EdgeInsets.only(left: 40, top: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Text(
                  comment,

                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
