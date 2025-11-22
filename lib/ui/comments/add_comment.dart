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
    // Lấy Theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currentUser = context.read<AuthManager>().user;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,

          border: Border(
            top: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 45),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Replying @${replyingTo!.userId}",

                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Avatar(userId: currentUser?.id ?? 'Ẩn danh'),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,

                    style: textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? "Comment here..."
                          : "Reply to user...",

                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      filled: true,

                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSend(controller.text);
                      controller.clear();
                    }
                  },

                  icon: Icon(Icons.send, color: colorScheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
