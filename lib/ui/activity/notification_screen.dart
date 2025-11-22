import 'package:ct312h_project/ui/activity/notification_item.dart';
import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<NotificationManager>();
    final notifications = manager.notifications;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (notifications.isEmpty) {
      return Scaffold(
        appBar: _buildAppbar(context, manager),
        body: Center(
          child: Text('No notifications yet', style: textTheme.bodyMedium),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppbar(context, manager, hasItem: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return NotificationItem(noti: notif);
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppbar(
    BuildContext context,
    NotificationManager manager, {
    bool hasItem = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      elevation: 0,

      title: Text('Activity', style: textTheme.titleLarge),
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),

          color: colorScheme.surfaceContainerHighest,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'readAll',
              child: Text('Mark all as read', style: textTheme.bodyMedium),
            ),
            PopupMenuItem(
              value: 'deleteAll',
              child: Text(
                'Delete all',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
          onSelected: (value) async {
            if (!hasItem) return;

            if (value == 'readAll') {
              await manager.readAll();
            } else if (value == 'deleteAll') {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    title: Text(
                      'Delete all notifications',
                      style: textTheme.titleLarge,
                    ),
                    content: Text(
                      'Are you sure you want to delete all notifications?',
                      style: textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text(
                          'Delete',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          await manager.deleteAll();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
