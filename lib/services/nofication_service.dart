import 'package:pocketbase/pocketbase.dart';
import 'package:ct312h_project/models/notification.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';

class NotificationService {
  Future<List<Notification>> fetchNotifications(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb
          .collection('notifications')
          .getFullList(filter: 'userId = "$userId"', sort: '-created');

      return records.map((r) {
        return Notification(
          id: r.id,
          userId: r.data['userId'] ?? '',
          postId: r.data['postId'],
          commentId: r.data['commentId'],
          type: r.data['type'] ?? '',
          message: r.data['message'] ?? '',
          isRead: r.data['isRead'] ?? false,
          createdAt: DateTime.parse(r.data['created']),
        );
      }).toList();
    } catch (e) {
      print('fetchNotifications error: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb
          .collection('notifications')
          .update(notificationId, body: {'isRead': true});
    } catch (e) {
      print('markAsRead error: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String message,
    String? postId,
    String? commentId,
  }) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb
          .collection('notifications')
          .create(
            body: {
              'userId': userId,
              'postId': postId,
              'commentId': commentId,
              'type': type,
              'message': message,
              'isRead': false,
            },
          );
    } catch (e) {
      print('createNotification error: $e');
    }
  }
}
