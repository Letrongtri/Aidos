import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:ct312h_project/ui/user/edit_profile_screen.dart';
import 'package:ct312h_project/viewmodels/pofile_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasLoaded = false;
  List<Post> _repliedPosts = [];
  bool _isRepliedLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDataOnce());
  }

  Future<void> _loadDataOnce() async {
    if (_hasLoaded) return;
    _hasLoaded = true;

    final vm = context.read<ProfileManager>();
    final postsManager = context.read<PostsManager>();

    await vm.loadUser();

    if (vm.user == null) return;

    // 🔹 Fetch posts (feed)
    if (postsManager.posts.isEmpty) {
      await postsManager.fetchPosts();
    }

    // 🔹 Fetch replied posts
    setState(() => _isRepliedLoading = true);
    final replied = await postsManager.getUserRepliedPosts(vm.user!.id);
    setState(() {
      _repliedPosts = replied;
      _isRepliedLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();
    final postsManager = context.watch<PostsManager>();

    if (vm.isLoading || vm.user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final user = vm.user!;
    final userPosts = postsManager.getUserPosts(user.id);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SlidingUpPanel(
          controller: vm.panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) => EditProfileScreen(
            panelController: vm.panelController,
            user: user,
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------ HEADER ------------------
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: vm.openEditPanel,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProfileHeader(user: user),
                ),

                const SizedBox(height: 15),

                // ------------------ TABS ------------------
                const TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Posts'),
                    Tab(text: 'Replied'),
                    Tab(text: 'Reposts'),
                  ],
                ),

                // ------------------ TAB CONTENT ------------------
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: User’s Posts
                      _buildPostList(userPosts, "No posts yet"),

                      // TAB 2: Replied Posts
                      _isRepliedLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _buildPostList(_repliedPosts, "No replies yet"),

                      // TAB 3: Reposts
                      _buildPostList([], "No reposts yet"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts, String emptyText) {
    if (posts.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: () async {
        final postsManager = context.read<PostsManager>();
        await postsManager.fetchPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) => SinglePostItem(post: posts[index]),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[900],
          backgroundImage: hasAvatar
              ? NetworkImage(user.avatarUrl!)
              : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
