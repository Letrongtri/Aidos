import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;
import 'package:ct312h_project/services/pocketbase_client.dart';

class NotificationManager extends ChangeNotifier {
  final List<app_model.Notification> _notifications = [];
  bool isLoading = false;
  String? currentUserId;

  List<app_model.Notification> get notifications => [..._notifications];
  List<app_model.Notification> get replyNotifications =>
      _notifications.where((n) => n.type == 'reply').toList();

  // 🧩 Fetch thông báo ban đầu
  Future<void> fetchNotifications(String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final pb = await getPocketbaseInstance();
      final result = await pb
          .collection('notifications')
          .getList(filter: 'userId="$userId"', sort: '-created');

      _notifications
        ..clear()
        ..addAll(
          result.items.map((r) => app_model.Notification.fromMap(r.toJson())),
        );

      _setupRealtimeListener(pb, userId);
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🧠 Realtime listener PocketBase
  void _setupRealtimeListener(PocketBase pb, String userId) {
    pb.collection('notifications').unsubscribe('*'); // clear old listener

    pb.collection('notifications').subscribe('*', (e) {
      if (e.record == null) return;
      final record = e.record!;
      final noti = app_model.Notification.fromMap(record.toJson());

      switch (e.action) {
        case 'create':
          _notifications.insert(0, noti);
          break;
        case 'update':
          final index = _notifications.indexWhere((n) => n.id == noti.id);
          if (index != -1) _notifications[index] = noti;
          break;
        case 'delete':
          _notifications.removeWhere((n) => n.id == noti.id);
          break;
      }

      notifyListeners();
    });
  }

  // 🟢 Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('notifications').update(id, body: {'isRead': true});

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }
}
