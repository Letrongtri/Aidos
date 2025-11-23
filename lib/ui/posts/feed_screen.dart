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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PostsManager>().fetchFeedPosts(isRefresh: true),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final postsManager = context.read<PostsManager>();
      if (!postsManager.isLoadingPosts && postsManager.hasMorePosts) {
        postsManager.fetchFeedPosts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final manager = context.watch<PostsManager>();

    final posts = manager.posts;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Image.asset("assets/images/logo.png", width: 30),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await manager.fetchFeedPosts(isRefresh: true);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: manager.isLoadingPostsInitial
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                ? Center(
                    child: Text("No posts yet", style: textTheme.bodyMedium),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    itemCount: posts.length + 1, // +1 cho loading footer
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: colorScheme.onSurface.withOpacity(0.12),
                    ),
                    itemBuilder: (context, idx) {
                      if (idx == posts.length) {
                        return _buildFooter(manager);
                      }

                      return SinglePostItem(post: posts[idx]);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(PostsManager manager) {
    if (manager.isLoadingPosts) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!manager.hasMorePosts && manager.posts.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "Bạn đã xem hết tin!",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
