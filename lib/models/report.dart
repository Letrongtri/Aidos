// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Report {
  final String id;
  final String? postId;
  final String? userId;
  final String reason;
  final DateTime createdAt;
  final DateTime? solvedAt;

  Report({
    required this.id,
    this.postId,
    this.userId,
    required this.reason,
    required this.createdAt,
    this.solvedAt,
  });

  Report copyWith({
    String? id,
    String? postId,
    String? userId,
    String? reason,
    DateTime? createdAt,
    DateTime? solvedAt,
  }) {
    return Report(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      solvedAt: solvedAt ?? this.solvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'userId': userId,
      'reason': reason,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'solvedAt': solvedAt?.millisecondsSinceEpoch,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      postId: map['postId'] != null ? map['postId'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
      reason: map['reason'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      solvedAt: map['solvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['solvedAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Report.fromJson(String source) =>
      Report.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Report(id: $id, postId: $postId, userId: $userId, reason: $reason, createdAt: $createdAt, solvedAt: $solvedAt)';
  }

  @override
  bool operator ==(covariant Report other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.reason == reason &&
        other.createdAt == createdAt &&
        other.solvedAt == solvedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        reason.hashCode ^
        createdAt.hashCode ^
        solvedAt.hashCode;
  }
}
