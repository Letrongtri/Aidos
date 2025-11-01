import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/comments/add_comment.dart';
import 'package:ct312h_project/ui/comments/comment_list.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:ct312h_project/ui/posts/detail_post_content.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// class DetailPostScreen extends StatelessWidget {
//   const DetailPostScreen({
//     super.key,
//     required this.id,
//     this.focusComment = false,
//   });
//   final String id;
//   final bool focusComment;

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // ChangeNotifierProvider(
//         //   create: (_) => getIt<DetailPostManager>()..fetchPostById(id),
//         // ),
//         // ChangeNotifierProvider(create: (_) => getIt<CommentManager>()),
//       ],
//       child: _DetailPostBody(focusComment: focusComment),
//     );
//   }
// }

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

  String selectedValue = 'Hotest';

  @override
  void initState() {
    // TODO: implement initState
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

    if (post == null) {
      return Scaffold(
        appBar: AppBar(elevation: 0, title: Text("Aido")),
        body: Center(child: Text("Không tìm thấy bài viết.")),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CommentManager(postId: post.id),
      child: Builder(
        builder: (context) {
          return _buildDetailPostScreen(context, post);
        },
      ),
    );
  }

  Widget _buildDetailPostScreen(BuildContext context, Post post) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        title: Text("Aido"),
        actions: [
          IconButton(
            onPressed: () {
              showPostActionsBottomSheet(
                context,
                onUpdate: () {
                  Navigator.pop(context);
                  context.push('/home/post', extra: post);
                },
                onDelete: () async {
                  Navigator.pop(context);

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text(
                        'Delete Post',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this post?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final postsManager = context.read<PostsManager>();
                      await postsManager.deletePost(post.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post deleted successfully'),
                          ),
                        );

                        context.go('/home/feed');
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
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            DetailPostContent(post: post),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedValue,
                  underline: SizedBox(),
                  items: <String>['Hotest', 'Newest'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                ),
              ],
            ),
            Divider(),
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
              postCommentCount: post.comments,
              parentComment: replyingTo,
            );

            if (context.mounted) {
              context.read<PostsManager>().incrementCommentCount(post.id);
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
}
