import 'dart:convert';

import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:pocketbase/pocketbase.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Post {
  final String id;
  final String userId;
  final String content;
  final String? topicId;
  final String? parentId;
  final int likes;
  final int comments;
  final int reposts;
  final int reports;
  final DateTime created;
  final DateTime updated;

  final User? user;
  final Topic? topic;
  final bool? isLiked;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.topicId,
    this.parentId,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.reports,
    required this.created,
    required this.updated,
    this.user,
    this.topic,
    this.isLiked,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    String? topicId,
    String? parentId,
    int? likes,
    int? comments,
    int? reposts,
    int? reports,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Topic? topic,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      topicId: topicId ?? this.topicId,
      parentId: parentId ?? this.parentId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      reports: reports ?? this.reports,
      created: createdAt ?? created,
      updated: updatedAt ?? updated,
      user: user ?? this.user,
      topic: topic ?? this.topic,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'content': content,
      'topicId': topicId,
      'parentId': parentId,
      'likes': likes,
      'comments': comments,
      'reposts': reposts,
      'reports': reports,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'user': user,
      'topic': topic,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      topicId: map['topicId'] != null ? map['topicId'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      likes: map['likes'] as int,
      comments: map['comments'] as int,
      reposts: map['reposts'] as int,
      reports: map['reports'] as int,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
      user: map['user'] != null ? map['user'] as User : null,
      topic: map['topic'] != null ? map['topic'] as Topic : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, content: $content, topicId: $topicId, parentId: $parentId, likeCount: $likes, commentCount: $comments, repostCount: $reposts, reportCount: $reports, createdAt: $created, updatedAt: $updated, user: $user, topic: $topic, isLiked: $isLiked)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.topicId == topicId &&
        other.parentId == parentId &&
        other.likes == likes &&
        other.comments == comments &&
        other.reposts == reposts &&
        other.reports == reports &&
        other.created == created &&
        other.updated == updated &&
        other.user == user &&
        other.topic == topic &&
        other.isLiked == isLiked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        topicId.hashCode ^
        parentId.hashCode ^
        likes.hashCode ^
        comments.hashCode ^
        reposts.hashCode ^
        reports.hashCode ^
        created.hashCode ^
        updated.hashCode ^
        user.hashCode ^
        topic.hashCode ^
        isLiked.hashCode;
  }

  factory Post.empty() => Post(
    id: '',
    userId: '',
    content: '',
    parentId: null,
    likes: 0,
    comments: 0,
    reposts: 0,
    reports: 0,
    created: DateTime.now(),
    updated: DateTime.now(),
  );

  factory Post.fromPocketbase({
    required RecordModel record,
    RecordModel? userRecord,
    RecordModel? topicRecord,
    bool? isLiked,
  }) {
    return Post(
      id: record.id,
      userId: record.getStringValue('userId'),
      content: record.getStringValue('content'),
      likes: record.getIntValue('likes'),
      comments: record.getIntValue('comments'),
      reposts: record.getIntValue('reposts'),
      reports: record.getIntValue('reports'),
      created: DateTime.parse(record.getStringValue('created')),
      updated: DateTime.parse(record.getStringValue('updated')),
      topicId: record.getStringValue('topicId'),
      parentId: record.getStringValue('parentId'),
      user: (userRecord != null && userRecord.data.isNotEmpty)
          ? User.fromMap(userRecord.data)
          : null,
      topic: (topicRecord != null && topicRecord.data.isNotEmpty)
          ? Topic.fromMap(topicRecord.data)
          : null,
      isLiked: isLiked,
    );
  }
}
