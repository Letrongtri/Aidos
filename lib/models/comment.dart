// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final int likeCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.likeCount,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    int? likeCount,
    int? relyCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      replyCount: relyCount ?? replyCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'parentId': parentId,
      'likeCount': likeCount,
      'relyCount': replyCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      likeCount: map['likeCount'] as int,
      replyCount: map['relyCount'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, userId: $userId, content: $content, parentId: $parentId, likeCount: $likeCount, relyCount: $replyCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.content == content &&
        other.parentId == parentId &&
        other.likeCount == likeCount &&
        other.replyCount == replyCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        parentId.hashCode ^
        likeCount.hashCode ^
        replyCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  factory Comment.empty() => Comment(
    id: '',
    postId: '',
    userId: '',
    content: '',
    parentId: null,
    likeCount: 0,
    replyCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
