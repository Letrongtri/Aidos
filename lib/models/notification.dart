// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Notification {
  final String id;
  final String? postId;
  final String? commentId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime created;

  Notification({
    required this.id,
    this.postId,
    this.commentId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.created,
  });

  Notification copyWith({
    String? id,
    String? postId,
    String? commentId,
    String? type,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      created: createdAt ?? created,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'commentId': commentId,
      'type': type,
      'message': message,
      'isRead': isRead,
      'created': created.toIso8601String(),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      postId: map['postId'] != null ? map['postId'] as String : null,
      commentId: map['commentId'] != null ? map['commentId'] as String : null,
      type: map['type'] as String,
      message: map['message'] as String,
      isRead: map['isRead'] as bool,
      created: DateTime.parse(map['created'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Notification(id: $id, postId: $postId, commentId: $commentId, type: $type, message: $message, isRead: $isRead, created: $created)';
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.postId == postId &&
        other.commentId == commentId &&
        other.type == type &&
        other.message == message &&
        other.isRead == isRead &&
        other.created == created;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        commentId.hashCode ^
        type.hashCode ^
        message.hashCode ^
        isRead.hashCode ^
        created.hashCode;
  }
}
