import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/user_service.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';

class PostScreen extends StatefulWidget {
  final Post? existingPost;
  const PostScreen({super.key, this.existingPost});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _contentController = TextEditingController();
  final _topicController = TextEditingController();
  final _userService = UserService();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    final post = widget.existingPost;
    if (post != null) {
      _contentController.text = post.content;
      _topicController.text = post.topic?.name ?? '';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<User?> _fetchCurrentUser() async => _userService.fetchCurrentUser();

  Future<void> _onPost(User user) async {
    FocusScope.of(context).unfocus();
    final content = _contentController.text.trim();
    final topic = _topicController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter post content')),
      );
      return;
    }

    setState(() => _isPosting = true);
    final postsManager = context.read<PostsManager>();

    try {
      if (widget.existingPost == null) {
        // ✅ Tạo bài mới
        await postsManager.createPost(
          userId: user.id,
          content: content,
          topicName: topic,
        );
      } else {
        // ✏️ Cập nhật bài cũ
        await postsManager.updatePost(
          postId: widget.existingPost!.id,
          content: content,
          topicName: topic,
        );
      }

      if (!mounted) return;

      _contentController.clear();
      _topicController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingPost == null
                ? 'Post created successfully!'
                : 'Post updated successfully!',
          ),
        ),
      );

      context.go('/home/feed');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPost != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<User?>(
          future: _fetchCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "User not found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final user = snapshot.data!;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // === Header (Cancel | Title | Post) ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context.go('/home/feed'),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          isEditing ? 'Edit Post' : 'New Post',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        TextButton(
                          onPressed: _isPosting ? null : () => _onPost(user),
                          child: Text(
                            _isPosting
                                ? 'Posting...'
                                : (isEditing ? 'Update' : 'Post'),
                            style: TextStyle(
                              color: _isPosting
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 20, 132, 237),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 12),

                    // === Body ===
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Avatar(userId: user.id, size: 25),
                          const SizedBox(width: 14),

                          // === Post input section ===
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Username + Topic inline
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: _topicController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Enter topic...',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Main content input
                                Expanded(
                                  child: TextFormField(
                                    controller: _contentController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "What's new?",
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                    expands: true,
                                    autofocus: isEditing ? false : true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
