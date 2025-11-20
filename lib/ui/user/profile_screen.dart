// lib/ui/user/profile_screen.dart
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/user/edit_profile_screen.dart';
import 'package:ct312h_project/ui/user/profile_replies_list.dart';
import 'package:ct312h_project/viewmodels/profile_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'profile_header.dart';
import 'profile_post_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasLoaded = false;
  List<Map<String, dynamic>> _repliedPosts = [];
  List<Post> _repostedPosts = [];
  bool _isRepliedLoading = true;
  bool _isRepostedLoading = true;

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

    await Future.wait([
      if (postsManager.posts.isEmpty) postsManager.fetchPosts(),
      () async {
        final replied = await postsManager.getUserRepliedPosts(vm.user!.id);
        if (mounted) {
          setState(() {
            _repliedPosts = replied;
            _isRepliedLoading = false;
          });
        }
      }(),
      () async {
        final reposted = await postsManager.getUserRepostedPosts(vm.user!.id);
        if (mounted) {
          setState(() {
            _repostedPosts = reposted;
            _isRepostedLoading = false;
          });
        }
      }(),
    ]);

    postsManager.addListener(_refreshRepostedPosts);
  }

  void _refreshRepostedPosts() async {
    final vm = context.read<ProfileManager>();
    final postsManager = context.read<PostsManager>();

    if (vm.user != null && mounted) {
      final reposted = await postsManager.getUserRepostedPosts(vm.user!.id);
      if (mounted) {
        setState(() {
          _repostedPosts = reposted;
        });
      }
    }
  }

  @override
  void dispose() {
    final postsManager = context.read<PostsManager>();
    postsManager.removeListener(_refreshRepostedPosts);
    super.dispose();
  }

  Future<void> _onRefreshPosts() async {
    await context.read<PostsManager>().fetchPosts();
  }

  Future<void> _onRefreshReposts() async {
    final postsManager = context.read<PostsManager>();
    final vm = context.read<ProfileManager>();

    await postsManager.fetchPosts();

    if (vm.user != null) {
      final reposted = await postsManager.getUserRepostedPosts(vm.user!.id);
      if (mounted) {
        setState(() => _repostedPosts = reposted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();
    final postsManager = context.watch<PostsManager>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (vm.user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("User not found", style: TextStyle(color: Colors.white)),
        ),
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
                  child: ProfileHeader(user: user),
                ),
                const SizedBox(height: 15),
                const TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Posts'),
                    Tab(text: 'Replied'),
                    Tab(text: 'Reposts'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ProfilePostList(
                        posts: userPosts,
                        emptyText: "No posts yet",
                        onRefresh: _onRefreshPosts,
                      ),
                      ProfileRepliesList(
                        repliedPosts: _repliedPosts,
                        isLoading: _isRepliedLoading,
                      ),
                      _isRepostedLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ProfilePostList(
                              posts: _repostedPosts,
                              emptyText: "No reposts yet",
                              onRefresh: _onRefreshReposts,
                            ),
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
}
