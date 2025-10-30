// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Like {
  final String id;
  final String userId;
  final String? postId;
  final String? commentId;
  final DateTime created;
  final DateTime updated;

  Like({
    required this.id,
    required this.userId,
    this.postId,
    this.commentId,
    required this.created,
    required this.updated,
  });

  Like copyWith({
    String? id,
    String? userId,
    String? postId,
    String? commentId,
    DateTime? created,
    DateTime? updated,
  }) {
    return Like(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'] as String,
      userId: map['userId'] as String,
      postId: map['postId'] != null ? map['postId'] as String : null,
      commentId: map['commentId'] != null ? map['commentId'] as String : null,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Like.fromJson(String source) =>
      Like.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Like(id: $id, userId: $userId, postId: $postId, commentId: $commentId, created: $created, updated: $updated)';
  }

  @override
  bool operator ==(covariant Like other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.postId == postId &&
        other.commentId == commentId &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        postId.hashCode ^
        commentId.hashCode ^
        created.hashCode ^
        updated.hashCode;
  }

  factory Like.fromPocketbase(RecordModel record) {
    return Like(
      id: record.id,
      userId: record.getStringValue('userId'),
      postId: record.getStringValue('postId'),
      commentId: record.getStringValue('commentId'),
      created: DateTime.parse(record.getStringValue('created')),
      updated: DateTime.parse(record.getStringValue('updated')),
    );
  }
}
