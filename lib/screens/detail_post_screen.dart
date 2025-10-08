import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/comments/add_comment.dart';
import 'package:ct312h_project/ui/comments/comment_list.dart';
import 'package:ct312h_project/ui/comments/comment_manager.dart';
import 'package:ct312h_project/ui/posts/detail_post_content.dart';
import 'package:flutter/material.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({super.key, required this.post});
  final Post post;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  String selectedValue = 'Hotest';
  final comments = CommentManager();

  final FocusNode _commentFocusNode = FocusNode();
  final _commentController = TextEditingController();
  Comment? replyingTo;

  void _addComment(String text) {
    setState(() {
      // comments.add(Comment(id: id, postId: postId, userId: userId, content: content, likeCount: likeCount, relyCount: relyCount, createdAt: createdAt, updatedAt: updatedAt))
      print("Gửi comment: $text (replyingTo: ${replyingTo?.id ?? 'root'})");
      replyingTo = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  void _onReply(Comment comment) {
    setState(() {
      replyingTo = comment;
    });

    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        title: Text("Aido"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            DetailPostContent(post: widget.post),
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
            CommentList(comments: comments, onReply: _onReply),
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
          onSend: _addComment,
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
