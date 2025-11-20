import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Stream để UI hoặc Router lắng nghe khi user tap vào thông báo
  final StreamController<String?> _onNotificationClick =
      StreamController<String?>.broadcast();
  Stream<String?> get onNotificationClick => _onNotificationClick.stream;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'aidos_anonymous_social_media',
    'Aidos',
    description: 'Thông báo từ Aidos',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('kar98k'),
  );

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('android12splash');
    const DarwinInitializationSettings isoSettings =
        DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: isoSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Khi user tap vào thông báo, đẩy payload vào stream
        _onNotificationClick.add(response.payload);
      },
    );

    // Yêu cầu quyền trên android 13+
    _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Yêu cầu quyền trên iOS
    _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload, // Dùng payload để chứa route (VD: /post/123)
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: 'android12splash',
      sound: channel.sound,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
