import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({super.key, required this.noti});

  final app_model.Notification noti;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<NotificationManager>();

    return Dismissible(
      key: ValueKey(noti.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) {
        return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete notification'),
            content: const Text('Do you want to delete this notification?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async =>
          await manager.deleteNotification(noti.id),
      child: ListTile(
        tileColor: !noti.isRead ? Colors.grey[900] : Colors.black,
        leading: Icon(
          noti.type == app_model.NotificationType.like.name
              ? Icons.favorite
              : noti.type == app_model.NotificationType.comment.name
              ? Icons.chat_bubble_outline
              : Icons.notifications,
          color: noti.type == app_model.NotificationType.like.name
              ? Colors.redAccent
              : Colors.blueAccent,
        ),
        title: Text(
          noti.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: !noti.isRead ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          noti.body,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: !noti.isRead ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          Format.getTimeDifference(noti.created),
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () async {
          await manager.markAsRead(noti.id);

          if (noti.type == app_model.NotificationType.post.name ||
              noti.type == app_model.NotificationType.like.name ||
              noti.type == app_model.NotificationType.reply.name ||
              noti.type == app_model.NotificationType.comment.name) {
            if (context.mounted) {
              if (noti.targetId == null) return;
              context.pushNamed(
                AppRouteName.detailPost.name,
                pathParameters: {'id': noti.targetId!},
              );
            }
          }
        },
      ),
    );
  }
}
