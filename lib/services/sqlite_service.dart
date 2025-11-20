import 'package:ct312h_project/models/notification.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('notifications.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notifications(
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            body TEXT,
            type TEXT,
            targetId TEXT,
            isRead INTEGER,
            created TEXT,
            updated TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNotification(Notification notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Notification>> getNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'created DESC',
    );

    final notis = List.generate(
      maps.length,
      (i) => Notification.fromSqlite(maps[i]),
    );
    return notis;
  }

  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead() async {
    final db = await database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM notifications WHERE isRead = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete('notifications');
  }
}
