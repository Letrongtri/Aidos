import 'dart:convert';

import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:flutter/foundation.dart'; // Để dùng listEquals nếu cần, hoặc giữ nguyên logic cũ
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

  // --- UPDATE: Thêm list images ---
  final List<String> images;

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
    this.images = const [], // Mặc định là list rỗng
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
    List<String>? images, // Thêm vào copyWith
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
      images: images ?? this.images, // Cập nhật images
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
      'images': images, // Thêm vào map
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
      // Parse images an toàn từ List dynamic
      images: map['images'] != null
          ? List<String>.from(map['images'])
          : const [],
      user: map['user'] != null ? map['user'] as User : null,
      topic: map['topic'] != null ? map['topic'] as Topic : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, content: $content, topicId: $topicId, parentId: $parentId, likeCount: $likes, commentCount: $comments, repostCount: $reposts, reportCount: $reports, created: $created, updated: $updated, images: $images, user: $user, topic: $topic, isLiked: $isLiked)';
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
        listEquals(
          other.images,
          images,
        ) && // Dùng listEquals để so sánh nội dung list
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
        images.hashCode ^
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
    images: const [], // Khởi tạo rỗng
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
      // Lấy list file names từ PocketBase record
      images: record.getListValue<String>('images'),
      user: (userRecord != null && userRecord.data.isNotEmpty)
          ? User.fromMap(userRecord.data)
          : null,
      topic: (topicRecord != null && topicRecord.data.isNotEmpty)
          ? Topic.fromMap(topicRecord.data)
          : null,
      isLiked: isLiked,
    );
  }

  Post copyWithRawData(Map<String, dynamic> rawData, bool? isLiked) {
    return Post(
      id: rawData['id'] as String,
      userId: rawData['userId'] as String,
      content: rawData['content'] as String,
      topicId: rawData['topicId'] != null ? rawData['topicId'] as String : null,
      parentId: rawData['parentId'] != null
          ? rawData['parentId'] as String
          : null,
      likes: rawData['likes'] as int,
      comments: rawData['comments'] as int,
      reposts: rawData['reposts'] as int,
      reports: rawData['reports'] as int,
      created: DateTime.parse(rawData['created'] as String),
      updated: DateTime.parse(rawData['updated'] as String),
      images: rawData['images'] != null
          ? List<String>.from(rawData['images'])
          : const [],
      isLiked: isLiked,
    );
  }
}
