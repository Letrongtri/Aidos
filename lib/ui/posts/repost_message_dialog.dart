import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showRepostMessageDialog(
  BuildContext context,
  String postId,
) async {
  final theme = Theme.of(context);
  final controller = TextEditingController();

  final messenger = ScaffoldMessenger.of(context);

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      title: Text(
        "Repost",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: controller,
        maxLines: 5,
        style: TextStyle(color: theme.colorScheme.primary),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          hintText: "Enter your reposted message",
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final value = controller.text.trim();
            if (value.isEmpty) return;

            try {
              await context.read<PostsManager>().createRepost(
                content: value,
                parentPostId: postId,
              );

              if (context.mounted) Navigator.pop(context);

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Reposted successfully!',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Error reposting: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          child: const Text("Repost"),
        ),
      ],
    ),
  );
}
