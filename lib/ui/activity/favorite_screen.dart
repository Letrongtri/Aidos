import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _currentIndexTab = 0;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final vm = context.read<NotificationManager>();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationManager>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          title: Text(
            'Activity',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(AppBar().preferredSize.height),
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
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
                      borderRadius: BorderRadius.circular(8.r),
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
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Tab(text: 'Replies'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final notifications = vm.notifications;
            final replyNotifications = notifications
                .where((n) => n.type == 'reply')
                .toList();

            return Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: TabBarView(
                children: [
                  _buildNotificationList(notifications, vm),
                  _buildNotificationList(replyNotifications, vm),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<app_model.Notification> notifications,
    NotificationManager vm,
  ) {
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
          Divider(color: Colors.grey.shade800, height: 0.h),
      itemBuilder: (context, index) {
        final n = notifications[index];
        final isUnread = !n.isRead;

        return ListTile(
          tileColor: isUnread ? Colors.grey[900] : Colors.black,
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 15..sp,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            _formatTime(n.created),
            style: TextStyle(color: Colors.grey, fontSize: 12..sp),
          ),
          onTap: () async {
            await vm.markAsRead(n.id);
          },
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
