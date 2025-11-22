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
    if (_hasLoaded || !mounted) return;
    _hasLoaded = true;

    final vm = context.read<ProfileManager>();
    final postsManager = context.read<PostsManager>();

    await vm.loadUser();
    if (!mounted || vm.user == null) return;

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

    if (mounted) {
      postsManager.addListener(_refreshRepostedPosts);
    }
  }

  void _refreshRepostedPosts() async {
    if (!mounted) return;

    final vm = context.read<ProfileManager>();
    final postsManager = context.read<PostsManager>();

    if (vm.user != null) {
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
    try {
      final postsManager = context.read<PostsManager>();
      postsManager.removeListener(_refreshRepostedPosts);
    } catch (e) {
      debugPrint('Error removing listener: $e');
    }
    super.dispose();
  }

  Future<void> _onRefreshPosts() async {
    if (!mounted) return;
    await context.read<PostsManager>().fetchPosts();
  }

  Future<void> _onRefreshReposts() async {
    if (!mounted) return;

    final postsManager = context.read<PostsManager>();
    final vm = context.read<ProfileManager>();

    await postsManager.fetchPosts();

    if (vm.user != null && mounted) {
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (vm.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.secondary),
        ),
      );
    }

    if (vm.user == null) {
      return Scaffold(
        body: Center(child: Text("User not found", style: textTheme.bodyLarge)),
      );
    }

    final user = vm.user!;
    final userPosts = postsManager.getUserPosts(user.id);

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context)!;

          tabController.addListener(() async {
            if (tabController.indexIsChanging) return;
            if (tabController.index == 1) {
              // Tab Replied
              setState(() {
                _isRepliedLoading = true;
              });
              final replied = await postsManager.getUserRepliedPosts(user.id);
              if (mounted) {
                setState(() {
                  _repliedPosts = replied;
                  _isRepliedLoading = false;
                });
              }
            }
          });

          return Scaffold(
            body: SlidingUpPanel(
              controller: vm.panelController,
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              color: colorScheme.surfaceContainerHighest,
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
                          icon: Icon(
                            Icons.settings,
                            color: colorScheme.primary,
                          ),
                          onPressed: vm.openEditPanel,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileHeader(user: user),
                    ),
                    const SizedBox(height: 15),
                    TabBar(
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurface.withOpacity(
                        0.5,
                      ),
                      indicatorColor: colorScheme.secondary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: textTheme.titleLarge?.copyWith(fontSize: 16),
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Replied'),
                        Tab(text: 'Reposts'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ProfilePostList(
                            key: const ValueKey('profile_posts_tab'),
                            posts: userPosts,
                            emptyText: "No posts yet",
                            onRefresh: _onRefreshPosts,
                          ),
                          ProfileRepliesList(
                            key: const ValueKey('profile_replies_tab'),
                            repliedPosts: _repliedPosts,
                            isLoading: _isRepliedLoading,
                          ),
                          _isRepostedLoading
                              ? Center(
                                  key: const ValueKey(
                                    'profile_reposts_loading',
                                  ),
                                  child: CircularProgressIndicator(
                                    color: colorScheme.secondary,
                                  ),
                                )
                              : ProfilePostList(
                                  key: const ValueKey('profile_reposts_tab'),
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
          );
        },
      ),
    );
  }
}
