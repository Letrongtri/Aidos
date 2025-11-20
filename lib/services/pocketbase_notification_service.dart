import 'package:ct312h_project/models/notification.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseNotificationService {
  Future<void> subscribeToNotifications(
    Function(RecordSubscriptionEvent) onEvent,
  ) async {
    final pb = await getPocketbaseInstance();

    final userId = pb.authStore.record?.id;

    pb.collection('notifications').subscribe('*', (e) {
      // Chỉ xử lý nếu thông báo dành cho user hiện tại (nếu PocketBase rule chưa filter)
      if (e.record != null && e.record!.data['userId'] == userId) {
        onEvent(e);
      }
    });
  }

  Future<void> unsubscribe() async {
    final pb = await getPocketbaseInstance();
    pb.collection('notifications').unsubscribe();
  }

  static Future<void> createNotification(Notification notification) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('notifications').create(body: notification.toMap());
  }

  Future<List<Notification>> getAllNotifications() async {
    final pb = await getPocketbaseInstance();
    final userId = pb.authStore.record?.id;
    if (userId == null) return [];

    final result = await pb
        .collection('notifications')
        .getList(query: {'userId': userId});

    return result.items.map((e) => Notification.fromMap(e.toJson())).toList();
  }

  Future<void> deleteNotification(String notificationId) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('notifications').delete(notificationId);
  }

  Future<void> deleteAllNotifications() async {
    final pb = await getPocketbaseInstance();

    final myUserId = pb.authStore.record?.id;
    if (myUserId == null) return;

    const batchSize = 50;

    while (true) {
      // Lấy batch notifications
      final notifications = await pb
          .collection('notifications')
          .getList(page: 1, perPage: batchSize, filter: 'userId="$myUserId"');

      if (notifications.items.isEmpty) break;

      // Xóa từng notification trong batch
      for (var notification in notifications.items) {
        await pb.collection('notifications').delete(notification.id);
      }
    }
  }

  Future<void> markAllAsRead() async {
    final pb = await getPocketbaseInstance();
    final myUserId = pb.authStore.record?.id;
    if (myUserId == null) return;

    const batchSize = 50;

    while (true) {
      // Lấy batch notifications
      final notifications = await pb
          .collection('notifications')
          .getList(
            page: 1,
            perPage: batchSize,
            filter: 'userId="$myUserId" && isRead=false',
          );

      if (notifications.items.isEmpty) break;

      for (var notification in notifications.items) {
        await pb
            .collection('notifications')
            .update(notification.id, body: {'isRead': true});
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final pb = await getPocketbaseInstance();

    await pb
        .collection('notifications')
        .update(notificationId, body: {'isRead': true});
  }
}
