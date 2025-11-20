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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (repliedPosts.isEmpty) {
      return const Center(
        child: Text('No replies yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
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
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Text(
                  comment,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
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
