import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Post {
  final String id;
  final String userId;
  final String content;
  final String topicId;
  final String parentId;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int reportCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.topicId,
    required this.parentId,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.reportCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    String? topicId,
    String? parentId,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    int? reportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      topicId: topicId ?? this.topicId,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'content': content,
      'topicId': topicId,
      'parentId': parentId,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'repostCount': repostCount,
      'reportCount': reportCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      topicId: map['topicId'] as String,
      parentId: map['parentId'] as String,
      likeCount: map['likeCount'] as int,
      commentCount: map['commentCount'] as int,
      repostCount: map['repostCount'] as int,
      reportCount: map['reportCount'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, content: $content, topicId: $topicId, parentId: $parentId, likeCount: $likeCount, commentCount: $commentCount, repostCount: $repostCount, reportCount: $reportCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.topicId == topicId &&
        other.parentId == parentId &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.repostCount == repostCount &&
        other.reportCount == reportCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        topicId.hashCode ^
        parentId.hashCode ^
        likeCount.hashCode ^
        commentCount.hashCode ^
        repostCount.hashCode ^
        reportCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
