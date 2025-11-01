import 'package:ct312h_project/services/notification_service.dart';
import 'package:ct312h_project/models/notification.dart' as app_noti;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NotificationManager with ChangeNotifier {
  final NotificationService _service = NotificationService();
  final List<app_noti.Notification> _notifications = [];

  List<app_noti.Notification> get notifications =>
      List.unmodifiable(_notifications);

  NotificationManager() {
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _service.getAllNotifications();
    _notifications
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> sendNotification(
    String userId,
    String message, {
    String type = 'info',
  }) async {
    final model = app_noti.Notification(
      id: const Uuid().v4(),
      type: type,
      message: message,
      isRead: false,
      created: DateTime.now(),
    );

    // hiển thị noti
    await _service.showNotification(title: type, body: message);
    // lưu vào db
    await _service.saveNotification(model);

    _notifications.insert(0, model);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final newNoti = _notifications[index].copyWith(isRead: true);
      _notifications[index] = newNoti;
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    _notifications.clear();
    notifyListeners();
  }
}
