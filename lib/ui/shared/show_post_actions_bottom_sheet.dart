import 'package:flutter/material.dart';

void showPostActionsBottomSheet(
  BuildContext context, {
  required void Function()? onUpdate,
  void Function()? onDelete,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  showModalBottomSheet(
    context: context,

    backgroundColor: colorScheme.surfaceContainerHighest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              title: Text(
                "Update",

                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.update, color: colorScheme.primary),
              onTap: onUpdate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              tileColor: colorScheme.surface,
            ),
            const SizedBox(height: 10),

            ListTile(
              title: Text(
                "Delete",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.delete, color: colorScheme.error),
              onTap: onDelete,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              tileColor: colorScheme.surface,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
