import 'package:flutter/material.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;

class NotificationManager extends ChangeNotifier {
  List<app_model.Notification> _notifications = [];

  List<app_model.Notification> get notifications => _notifications;
  List<app_model.Notification> get replyNotifications =>
      _notifications.where((n) => n.type == 'reply').toList();

  Future<void> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500)); // fake delay
    _notifications = [
      app_model.Notification(
        id: '1',
        userId: 'u1',
        postId: 'p1',
        commentId: null,
        type: 'like',
        message: 'Someone liked your post 💖',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      app_model.Notification(
        id: '2',
        userId: 'u1',
        postId: 'p2',
        commentId: 'c3',
        type: 'reply',
        message: 'Someone replied to your comment 💬',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}
