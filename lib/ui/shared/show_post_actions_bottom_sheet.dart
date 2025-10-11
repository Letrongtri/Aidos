import 'package:flutter/material.dart';

void showPostActionsBottomSheet(
  BuildContext context, {
  required void Function()? onUpdate,
  void Function()? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            ListTile(
              title: Text("Update"),
              trailing: Icon(Icons.update),
              onTap: () {
                onUpdate?.call();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
            ),

            SizedBox(height: 10),
            ListTile(
              title: Text("Share"),
              trailing: Icon(Icons.share),
              onTap: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
            ),

            SizedBox(height: 10),
            ListTile(
              title: Text("Hide"),
              trailing: Icon(Icons.visibility_off),
              onTap: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
            ),

            SizedBox(height: 10),
            ListTile(
              title: Text("Report"),
              trailing: Icon(Icons.report),
              onTap: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
              textColor: Colors.red,
              iconColor: Colors.red,
            ),

            SizedBox(height: 10),
            ListTile(
              title: Text("Delete"),
              trailing: Icon(Icons.delete),
              onTap: () {
                onDelete?.call();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: const Color.fromARGB(255, 41, 41, 41),
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
