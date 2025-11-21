import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<void> _fetchPosts;

  @override
  void initState() {
    super.initState();
    _fetchPosts = context.read<PostsManager>().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.select<PostsManager, List<Post>>(
      (postsManager) => postsManager.posts,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Image.asset("assets/images/logo.png", width: 30),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
            future: _fetchPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (posts.isEmpty) {
                  return Center(
                    child: Text("No posts yet", style: textTheme.bodyMedium),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, idx) =>
                      SinglePostItem(post: posts[idx]),
                );
              }

              return Center(
                child: CircularProgressIndicator(color: colorScheme.secondary),
              );
            },
          ),
        ),
      ),
    );
  }
}
