// lib/ui/user/profile_post_list.dart
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:flutter/material.dart';

class ProfilePostList extends StatelessWidget {
  final List<Post> posts;
  final String emptyText;
  final Future<void> Function() onRefresh;

  const ProfilePostList({
    super.key,
    required this.posts,
    required this.emptyText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: onRefresh,
      child: ListView.separated(
        separatorBuilder: (_, __) => const Divider(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) => SinglePostItem(post: posts[index]),
      ),
    );
  }
}
