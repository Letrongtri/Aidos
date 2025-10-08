import 'package:ct312h_project/ui/posts/posts_manager.dart';
import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final postsManager = PostsManager();

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        toolbarHeight: 40,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Image.asset("assets/images/logo.png", width: 30),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: postsManager.postCount,
            itemBuilder: (context, idx) =>
                SinglePostItem(post: postsManager.posts[idx]),
          ),
        ),
      ),
    );
  }
}
