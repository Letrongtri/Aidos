// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum NotificationType { post, comment, reply, like, user, system }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? targetId;
  final bool isRead;
  final DateTime created;
  final DateTime updated;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.targetId,
    this.isRead = false,
    required this.created,
    required this.updated,
  });

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? targetId,
    bool? isRead,
    DateTime? created,
    DateTime? updated,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'targetId': targetId,
      'isRead': isRead,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String,
      targetId: map['targetId'] as String,
      isRead: map['isRead'] as bool,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, title: $title, body: $body, type: $type, targetId: $targetId, isRead: $isRead, created: $created, updated: $updated)';
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.targetId == targetId &&
        other.isRead == isRead &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        targetId.hashCode ^
        isRead.hashCode ^
        created.hashCode ^
        updated.hashCode;
  }

  factory Notification.fromSqlite(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String,
      targetId: map['targetId'] as String,
      isRead: map['isRead'] as int == 1,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
    );
  }
}
