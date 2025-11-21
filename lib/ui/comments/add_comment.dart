import 'package:ct312h_project/models/comment.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddComment extends StatelessWidget {
  const AddComment({
    super.key,
    required this.controller,
    required this.focusNode,
    this.replyingTo,
    required this.onSend,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Comment? replyingTo;
  final Function(String text) onSend;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthManager>().user;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade800)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyingTo != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Replying @${replyingTo!.userId}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Avatar(userId: currentUser?.id ?? 'Ẩn danh'),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? "Comment here"
                          : "Reply ${replyingTo!.userId}",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    onSend(controller.text);
                    controller.clear();
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
