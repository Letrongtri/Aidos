import 'package:flutter/material.dart';

void showPostActionsBottomSheet(
  BuildContext context, {
  required void Function()? onUpdate,
  void Function()? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Update"),
              trailing: const Icon(Icons.update),
              onTap: onUpdate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Delete"),
              trailing: const Icon(Icons.delete),
              onTap: onDelete,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
