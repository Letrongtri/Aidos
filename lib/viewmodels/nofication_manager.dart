import 'package:flutter/material.dart';
import 'package:ct312h_project/models/notification.dart' as app_model;
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

class NotificationManager extends ChangeNotifier {
  List<app_model.Notification> _notifications = [];
  bool isLoading = false;
  String? currentUserId;

  List<app_model.Notification> get notifications => _notifications;

  List<app_model.Notification> get replyNotifications =>
      _notifications.where((n) => n.type == 'reply').toList();
  Future<void> fetchNotifications(String userId) async {
    isLoading = true;
    notifyListeners();

    currentUserId = userId;

    try {
      final pb = await getPocketbaseInstance();
      final result = await pb
          .collection('notifications')
          .getList(filter: 'userId="$userId"', sort: '-created');

      _notifications = result.items
          .map(
            (record) => app_model.Notification.fromMap({
              'id': record.id,
              'userId': record.getStringValue('userId'),
              'postId': record.getStringValue('postId'),
              'commentId': record.getStringValue('commentId'),
              'type': record.getStringValue('type'),
              'message': record.getStringValue('message'),
              'isRead': record.getBoolValue('isRead'),
              'createdAt': DateTime.parse(
                record.getStringValue('created'),
              ).millisecondsSinceEpoch,
            }),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      _notifications = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
      debugPrint('Error markAsRead: $e');
    }
  }
}
