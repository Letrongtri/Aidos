// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ct312h_project/models/user.dart';
import 'package:pocketbase/pocketbase.dart';

class Comment {
  final String? id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final String? rootId;
  final int likesCount;
  final int replyCount;
  final DateTime created;
  final DateTime updated;

  final User? user;
  final bool? isLiked;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.rootId,
    required this.likesCount,
    required this.replyCount,
    required this.created,
    required this.updated,
    this.user,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    String? rootId,
    int? likesCount,
    int? replyCount,
    DateTime? created,
    DateTime? updated,
    User? user,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      rootId: rootId ?? this.rootId,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      user: user ?? this.user,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'parentId': parentId,
      'rootId': rootId,
      'likeCount': likesCount,
      'replyCount': replyCount,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
      'user': user,
      'isLiked': isLiked,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] != null ? map['id'] as String : null,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      rootId: map['rootId'] != null ? map['rootId'] as String : null,
      likesCount: map['likesCount'] as int,
      replyCount: map['replyCount'] as int,
      created: DateTime.parse(map['created'] as String),
      updated: DateTime.parse(map['updated'] as String),
      user: map['user'] != null ? map['user'] as User : null,
      isLiked: map['isLiked'] != null ? map['isLiked'] as bool : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, userId: $userId, content: $content, parentId: $parentId, rootId: $rootId, likesCount: $likesCount, replyCount: $replyCount, createdAt: $created, updatedAt: $updated, user: $user, isLiked: $isLiked)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.content == content &&
        other.parentId == parentId &&
        other.rootId == rootId &&
        other.likesCount == likesCount &&
        other.replyCount == replyCount &&
        other.created == created &&
        other.updated == updated &&
        other.user == user &&
        other.isLiked == isLiked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        parentId.hashCode ^
        rootId.hashCode ^
        likesCount.hashCode ^
        replyCount.hashCode ^
        created.hashCode ^
        updated.hashCode ^
        user.hashCode ^
        isLiked.hashCode;
  }

  factory Comment.empty() => Comment(
    id: '',
    postId: '',
    userId: '',
    content: '',
    parentId: null,
    rootId: null,
    likesCount: 0,
    replyCount: 0,
    created: DateTime.now(),
    updated: DateTime.now(),
  );

  factory Comment.fromPocketbase({
    required RecordModel record,
    RecordModel? userRecord,
    bool? isLiked,
  }) {
    return Comment(
      id: record.id,
      postId: record.getStringValue('postId'),
      userId: record.getStringValue('userId'),
      content: record.getStringValue('content'),
      likesCount: record.getIntValue('likesCount'),
      replyCount: record.getIntValue('replyCount'),
      created: DateTime.parse(record.getStringValue('created')),
      updated: DateTime.parse(record.getStringValue('updated')),
      parentId: record.getStringValue('parentId'),
      rootId: record.getStringValue('rootId'),
      user: (userRecord != null && userRecord.data.isNotEmpty)
          ? User.fromMap(userRecord.data)
          : null,
      isLiked: isLiked,
    );
  }

  Map<String, dynamic> toPocketBase() {
    return <String, dynamic>{
      'postId': postId,
      'content': content,
      'parentId': parentId,
      'rootId': rootId,
      'likeCount': likesCount,
      'replyCount': replyCount,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Comment copyWithRawData(Map<String, dynamic> data, bool isLiked) {
    return Comment(
      id: data['id'] != null ? data['id'] as String : null,
      postId: data['postId'] as String,
      userId: data['userId'] as String,
      content: data['content'] as String,
      parentId: data['parentId'] != null ? data['parentId'] as String : null,
      rootId: data['rootId'] != null ? data['rootId'] as String : null,
      likesCount: data['likesCount'] as int,
      replyCount: data['replyCount'] as int,
      created: DateTime.parse(data['created'] as String),
      updated: DateTime.parse(data['updated'] as String),
      isLiked: isLiked,
    );
  }
}
