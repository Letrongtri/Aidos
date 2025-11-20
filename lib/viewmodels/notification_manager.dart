import 'dart:convert';

import 'package:ct312h_project/services/local_notification_service.dart';
import 'package:ct312h_project/services/pocketbase_notification_service.dart';
import 'package:ct312h_project/services/sqlite_service.dart';
import 'package:ct312h_project/models/notification.dart' as notification_model;
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class NotificationManager extends ChangeNotifier {
  final SqliteService _sqliteService = SqliteService();
  final PocketBaseNotificationService _pbService =
      PocketBaseNotificationService();
  final LocalNotificationService _localNotifService;

  List<notification_model.Notification> _notifications = [];
  List<notification_model.Notification> get notifications => _notifications;

  int _unreadCount = 0;

  NotificationManager(this._localNotifService);

  int get unreadCount => _unreadCount;

  Future<void> init() async {
    await _loadFromLocal();
    await loadFromServer();
    _startRealtimeListener();
  }

  Future<void> _loadFromLocal() async {
    _notifications = await _sqliteService.getNotifications();
    _unreadCount = await _sqliteService.getUnreadCount();
    notifyListeners();
  }

  Future<void> loadFromServer() async {
    final serverNotis = await _pbService.getAllNotifications();

    // đồng bộ giữa server và sqlite nhưng noti của user hien tai
    for (final noti in serverNotis) {
      if (_notifications.any((n) => n.id == noti.id)) continue;
      await _sqliteService.insertNotification(noti);
      _notifications.insert(0, noti);
    }
    _unreadCount = await _sqliteService.getUnreadCount();
    notifyListeners();
  }

  void _startRealtimeListener() {
    _pbService.subscribeToNotifications((RecordSubscriptionEvent event) async {
      if (event.action == 'create') {
        // 1. Parse dữ liệu từ PocketBase
        final newNotif = notification_model.Notification.fromMap(
          event.record!.toJson(),
        );

        // 2. Lưu vào SQLite
        await _sqliteService.insertNotification(newNotif);

        // 3. Cập nhật UI List
        _notifications.insert(0, newNotif);
        _unreadCount++;
        notifyListeners();

        // 4. Hiển thị Local Notification
        // Tạo payload để Router điều hướng. VD: type=post&id=123
        final payload = jsonEncode({
          'type': newNotif.type,
          'id': newNotif.targetId,
        });

        await _localNotifService.showNotification(
          id: newNotif.created.millisecondsSinceEpoch ~/ 1000,
          title: newNotif.title,
          body: newNotif.body,
          payload: payload,
        );
      }
    });
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((element) => element.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Cập nhật UI Optimistic
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();

      // Cập nhật DB
      await _sqliteService.markAsRead(id);

      // Optional: Gọi API update lên PocketBase để sync trạng thái
      await _pbService.markAsRead(id);
    }
  }

  Future<void> readAll() async {
    await _sqliteService.markAllAsRead();
    await _pbService.markAllAsRead();
    _notifications = _notifications
        .map((e) => e.copyWith(isRead: true))
        .toList();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _sqliteService.deleteAllNotifications();
    await _pbService.deleteAllNotifications();
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _sqliteService.deleteNotification(id);
    await _pbService.deleteNotification(id);
    _notifications.removeWhere((element) => element.id == id);
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _pbService.unsubscribe();
    super.dispose();
  }
}
