import 'dart:io';
import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  bool _isPosting = false;
  List<XFile> _selectedImages = [];

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

  Future<void> _pickImages() async {
    final theme = Theme.of(context);
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.length > 0) {
        setState(() {
          _selectedImages.addAll(images);
          if (_selectedImages.length > 4) {
            _selectedImages = _selectedImages.sublist(0, 4);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Maximum 4 images allowed',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking images: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickCamera() async {
    final theme = Theme.of(context);
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (_selectedImages.length < 4) {
            _selectedImages.add(image);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Maximum 4 images allowed',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error taking photo: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _onPost() async {
    FocusScope.of(context).unfocus();
    final content = _contentController.text.trim();
    final topic = _topicController.text.trim();
    final theme = Theme.of(context);

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter post content',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);
    final postsManager = context.read<PostsManager>();
    Post? newPost;

    try {
      if (widget.existingPost == null) {
        newPost = await postsManager.createPost(
          content: content,
          topicName: topic,
          images: _selectedImages.length > 0 ? _selectedImages : null,
        );
      } else {
        await postsManager.updatePost(
          postId: widget.existingPost!.id,
          content: content,
          topicName: topic,
          images: _selectedImages.length > 0 ? _selectedImages : null,
        );
      }

      if (!mounted) return;

      _contentController.clear();
      _topicController.clear();
      setState(() => _selectedImages.clear());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingPost == null
                ? 'Post created successfully!'
                : 'Post updated successfully!',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.existingPost == null) {
        if (newPost == null) return;
        context.pushNamed(
          AppRouteName.detailPost.name,
          pathParameters: {'id': newPost.id},
        );
        return;
      }

      if (context.mounted && context.canPop()) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPost != null;
    final user = context.watch<AuthManager>().user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: _buildAppBar(isEditing, context, theme),
      body: SafeArea(
        child: (user == null)
            ? const Center(
                child: Text(
                  "User not found",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: colorScheme.onSurface.withOpacity(0.12),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
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
                                    TextFormField(
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
                                      minLines: 3,
                                      autofocus: isEditing ? false : true,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMediaButtons(theme),
                                    const SizedBox(height: 16),
                                    if (_selectedImages.length > 0)
                                      _buildImageGrid(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(
                      _selectedImages[index].path,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaButtons(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: _selectedImages.length >= 4 ? null : _pickImages,
          icon: Icon(
            Icons.image_outlined,
            color: _selectedImages.length >= 4
                ? Colors.grey
                : theme.colorScheme.secondary,
          ),
          tooltip: 'Add images',
        ),
        IconButton(
          onPressed: _selectedImages.length >= 4 ? null : _pickCamera,
          icon: Icon(
            Icons.camera_alt_outlined,
            color: _selectedImages.length >= 4
                ? Colors.grey
                : theme.colorScheme.secondary,
          ),
          tooltip: 'Take photo',
        ),
      ],
    );
  }

  AppBar _buildAppBar(bool isEditing, BuildContext context, ThemeData theme) {
    return AppBar(
      leadingWidth: 100,
      leading: isEditing
          ? GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
      centerTitle: true,
      title: Text(
        isEditing ? 'Edit Post' : 'New Post',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPosting ? null : () => _onPost(),
          child: Text(
            _isPosting ? 'Posting...' : (isEditing ? 'Update' : 'Post'),
            style: TextStyle(
              color: _isPosting ? Colors.grey : theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
