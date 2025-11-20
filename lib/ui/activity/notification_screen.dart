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

    if (notifications.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppbar(context, manager),
        body: Center(child: Text('Chưa có thông báo')),
      );
    }

    return Scaffold(
      appBar: _buildAppbar(context, manager, hasItem: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      title: Text(
        'Hoạt động',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'readAll',
              child: Text('Đánh dấu đã đọc'),
            ),
            const PopupMenuItem(
              value: 'deleteAll',
              child: Text('Xóa tất cả'),
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
                    title: const Text('Xóa tất cả thông báo'),
                    content: const Text(
                      'Bạn có muốn xóa tất cả thông báo?',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Huỷ'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Xóa'),
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
