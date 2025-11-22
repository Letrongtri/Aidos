import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/viewmodels/viewmodels.dart';
import 'package:ct312h_project/ui/comments/add_comment.dart';
import 'package:ct312h_project/ui/comments/comment_list.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/ui/posts/detail_post_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({
    super.key,
    required this.id,
    this.focusComment = false,
  });
  final String id;
  final bool focusComment;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  final FocusNode _commentFocusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  Comment? replyingTo;

  @override
  void initState() {
    super.initState();
    if (widget.focusComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _commentFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = context.watch<PostsManager>().findPostById(widget.id);

    // Lấy Theme
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isMyPost = post?.userId == context.read<AuthManager>().user?.id;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("Aidos", style: textTheme.titleLarge),
        ),
        body: Center(
          child: Text("Không tìm thấy bài viết.", style: textTheme.bodyMedium),
        ),
      );
    }

    return ChangeNotifierProxyProvider<AuthManager, CommentManager>(
      create: (_) => CommentManager(postId: post.id),
      update: (context, value, previous) => previous!..updateAuthUser(value),
      child: Builder(
        builder: (context) {
          return _buildDetailPostScreen(context, post, isMyPost);
        },
      ),
    );
  }

  Widget _buildDetailPostScreen(
    BuildContext context,
    Post post,
    bool isMyPost,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(isMyPost, context, post),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<PostsManager>().refreshPost(widget.id);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              DetailPostContent(post: post),
              CommentList(
                postId: post.id,
                onReply: (comment) {
                  setState(() {
                    replyingTo = comment;
                  });
                  FocusScope.of(context).requestFocus(_commentFocusNode);
                },
              ),
            ],
          ),
        ),
      ),

      // bottom navigation
      bottomNavigationBar: AnimatedPadding(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddComment(
          controller: _commentController,
          focusNode: _commentFocusNode,
          replyingTo: replyingTo,
          onSend: (text) async {
            await context.read<CommentManager>().addComment(
              text: text,
              ownerId: post.userId,
              postCommentCount: post.comments,
              parentComment: replyingTo,
            );

            if (context.mounted) {
              context.read<PostsManager>().incrementCommentCount(post.id);

              context.read<ProfileManager>().fetchMyReplies();
            }
          },
          onCancelReply: () {
            setState(() {
              replyingTo = null;
            });
            _commentFocusNode.unfocus();
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isMyPost, BuildContext context, Post post) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return AppBar(
      elevation: 0,
      title: Text("Aidos", style: textTheme.titleLarge),
      actions: [
        if (isMyPost)
          IconButton(
            onPressed: () {
              showPostActionsBottomSheet(
                context,
                onUpdate: () {
                  Navigator.pop(context);
                  context.pushNamed(AppRouteName.post.name, extra: post);
                },
                onDelete: () async {
                  Navigator.pop(context);

                  final postsManager = context.read<PostsManager>();

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      title: Text('Delete Post', style: textTheme.titleLarge),
                      content: Text(
                        'Are you sure you want to delete this post?',
                        style: textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Delete',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await postsManager.deletePost(post.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Post deleted successfully',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            backgroundColor: colorScheme.secondary,
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting post: $e')),
                        );
                      }
                    }
                  }
                },
              );
            },
            icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
          ),
      ],
    );
  }
}
