import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ct312h_project/models/post.dart';
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

  Future<void> _onPost() async {
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
        await postsManager.createPost(content: content, topicName: topic);
      } else {
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

      if (context.mounted) {
        Navigator.pop(context);
      }
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

    final postsManager = context.watch<PostsManager>();
    final user = postsManager.currentUser;
    final isLoadingUser = postsManager.isLoadingUser;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: isLoadingUser
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.secondary),
              )
            : (user == null)
            ? Center(child: Text("User not found", style: textTheme.bodyLarge))
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              "Cancel",
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            isEditing ? 'Edit Post' : 'New Post',

                            style: textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: _isPosting ? null : () => _onPost(),
                            child: Text(
                              _isPosting
                                  ? 'Posting...'
                                  : (isEditing ? 'Update' : 'Post'),
                              style: textTheme.bodyLarge?.copyWith(
                                color: _isPosting
                                    ? colorScheme.onSurface.withOpacity(0.3)
                                    : colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        thickness: 1,
                        color: colorScheme.onSurface.withOpacity(0.12),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(userId: user.id, size: 25),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.username,

                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.grey[300],
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: TextField(
                                          controller: _topicController,

                                          style: textTheme.bodyMedium,
                                          decoration: InputDecoration(
                                            hintText: 'Enter topic...',
                                            hintStyle: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.5),
                                                ),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Expanded(
                                    child: TextFormField(
                                      controller: _contentController,

                                      style: textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        hintText: "What's new?",
                                        hintStyle: textTheme.bodyLarge
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.5),
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
              ),
      ),
    );
  }
}
