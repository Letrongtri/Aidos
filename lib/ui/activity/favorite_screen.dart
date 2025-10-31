import 'package:ct312h_project/viewmodels/nofication_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _currentIndexTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<NotificationManager>().fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationManager>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          title: const Text('Activity', style: TextStyle(color: Colors.white)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(AppBar().preferredSize.height),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                onTap: (index) => setState(() => _currentIndexTab = index),
                tabs: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndexTab == 0
                            ? Colors.transparent
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Tab(text: 'All'),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndexTab == 1
                            ? Colors.transparent
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Tab(text: 'Replies'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: TabBarView(
            children: [
              _buildNotificationList(vm.notifications),
              _buildNotificationList(vm.replyNotifications),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<app_model.Notification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade800, height: 0),
      itemBuilder: (context, index) {
        final n = notifications[index];
        return ListTile(
          leading: Icon(
            n.type == 'like'
                ? Icons.favorite
                : n.type == 'reply'
                ? Icons.chat_bubble_outline
                : Icons.notifications,
            color: n.type == 'like' ? Colors.redAccent : Colors.blueAccent,
          ),
          title: Text(
            n.message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          subtitle: Text(
            _formatTime(n.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: () => context.read<NotificationManager>().markAsRead(
            n.id,
          ), // 🧩 đánh dấu đã đọc
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
