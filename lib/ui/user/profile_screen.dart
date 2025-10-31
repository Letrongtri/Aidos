import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/user.dart';
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
  bool _hasLoadedUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<ProfileManager>();
    final postsManager = context.read<PostsManager>();

    if (!_hasLoadedUser) {
      _hasLoadedUser = true;
      vm.loadUser().then((_) {
        if (vm.user != null) {
          postsManager.fetchUserPosts(vm.user!.id);
          postsManager.fetchRepliedPosts(vm.user!.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();
    final postsManager = context.watch<PostsManager>();

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
          panelBuilder: (ScrollController sc) {
            if (vm.user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return EditProfileScreen(
              panelController: vm.panelController,
              user: vm.user!,
            );
          },
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu icon
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.dehaze, color: Colors.white),
                      onPressed: () {
                        if (vm.user != null) {
                          vm.openEditPanel();
                        }
                      },
                    ),
                  ),
                ),

                // Header
                if (vm.isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (vm.user != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ProfileHeader(user: vm.user!),
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
                      _buildPostList(
                        context,
                        postsManager.userPosts,
                        "No posts yet",
                      ),
                      _buildPostList(
                        context,
                        postsManager.repliedPosts,
                        "No replies yet",
                      ),
                      _buildPostList(
                        context,
                        postsManager.reposts,
                        "No reposts yet",
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

  /// 🧩 Danh sách post (cho phép like/comment)
  Widget _buildPostList(
    BuildContext context,
    List<Post> posts,
    String emptyText,
  ) {
    final postsManager = context.read<PostsManager>();

    if (posts.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final user = post.user;
        final hasAvatar =
            user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: hasAvatar
                        ? NetworkImage(user!.avatarUrl!)
                        : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user?.username ?? "Ẩn danh ${post.userId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(post.created),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
                ],
              ),

              const SizedBox(height: 10),

              // 🔹 Nội dung
              Text(
                post.content,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 12),

              // 🔹 Action bar (like/comment)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => postsManager.onLikePostPressed(post.id),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.isLiked == true
                              ? Colors.red
                              : Colors.grey.shade400,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${post.likes}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${post.comments}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.repeat, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${post.reposts}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return "${time.day}/${time.month}/${time.year}";
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
