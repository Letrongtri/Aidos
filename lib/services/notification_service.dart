import 'package:ct312h_project/models/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Database? _db;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings isoSettings =
        DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: isoSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;

    // init sqlite
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notifications.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notifications(
            id TEXT PRIMARY KEY,
            userId TEXT,
            postId TEXT,
            commentId TEXT,
            type TEXT,
            message TEXT,
            isRead INTEGER,
            created TEXT
          )
        ''');
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // Noti CRUD
  Future<void> saveNotification(Notification model) async {
    await _db!.insert(
      'notifications',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Notification>> getAllNotifications() async {
    final maps = await _db!.query('notifications', orderBy: 'created DESC');
    return maps.map((m) => Notification.fromMap(m)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _db!.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    await _db!.delete('notifications');
  }
}
