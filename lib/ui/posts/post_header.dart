// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/ui.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
            showPostActionsBottomSheet(
              context,
              onUpdate: () {
                Navigator.pop(context);
                context.push('/home/post', extra: post);
              },
              onDelete: () async {
                Navigator.pop(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: const Text(
                      'Delete Post',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this post?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    final postsManager = context.read<PostsManager>();
                    await postsManager.deletePost(post.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post deleted successfully'),
                        ),
                      );

                      context.go('/home/feed');
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
          icon: Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
