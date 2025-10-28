// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/models/user.dart';

class PostItemViewModel {
  final String id;
  final String userId;
  final String content;
  final String? topicId;
  final String? parentId;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;

  final String username;
  final String? topicName;
  final PostItemViewModel? parentPost;

  PostItemViewModel({
    required this.id,
    required this.userId,
    required this.content,
    this.topicId,
    this.parentId,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
    required this.username,
    required this.topicName,
    this.parentPost,
  });

  PostItemViewModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? topicId,
    String? parentId,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    String? username,
    String? topicName,
    PostItemViewModel? parentPost,
  }) {
    return PostItemViewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      topicId: topicId ?? this.topicId,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      username: username ?? this.username,
      topicName: topicName ?? this.topicName,
      parentPost: parentPost ?? this.parentPost,
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
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isLiked': isLiked,
      'username': username,
      'topicName': topicName,
      'parentPost': parentPost?.toMap(),
    };
  }

  factory PostItemViewModel.fromMap(Map<String, dynamic> map) {
    return PostItemViewModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      topicId: map['topicId'] != null ? map['topicId'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      likeCount: map['likeCount'] as int,
      commentCount: map['commentCount'] as int,
      repostCount: map['repostCount'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isLiked: map['isLiked'] as bool,
      username: map['username'] as String,
      topicName: map['topicName'] != null ? map['topicName'] as String : null,
      parentPost: map['parentPost'] != null
          ? PostItemViewModel.fromMap(map['parentPost'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostItemViewModel.fromJson(String source) =>
      PostItemViewModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostItemViewModel(id: $id, userId: $userId, content: $content, topicId: $topicId, parentId: $parentId, likeCount: $likeCount, commentCount: $commentCount, repostCount: $repostCount, createdAt: $createdAt, updatedAt: $updatedAt, isLiked: $isLiked, username: $username, topicName: $topicName, parentPost: $parentPost)';
  }

  @override
  bool operator ==(covariant PostItemViewModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.topicId == topicId &&
        other.parentId == parentId &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.repostCount == repostCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isLiked == isLiked &&
        other.username == username &&
        other.topicName == topicName &&
        other.parentPost == parentPost;
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
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isLiked.hashCode ^
        username.hashCode ^
        topicName.hashCode ^
        parentPost.hashCode;
  }

  factory PostItemViewModel.fromEntites({
    required Post post,
    required User user,
    Topic? topic,
    PostItemViewModel? parentPost,
    bool? isLiked,
  }) {
    return PostItemViewModel(
      id: post.id,
      userId: post.userId,
      content: post.content,
      likeCount: post.likes,
      commentCount: post.comments,
      repostCount: post.reposts,
      createdAt: post.created,
      updatedAt: post.updated,
      username: user.username,
      topicName: topic?.name,
      parentPost: parentPost,
      isLiked: isLiked ?? false,
    );
  }

  factory PostItemViewModel.empty() => PostItemViewModel(
    id: '',
    userId: '',
    content: '',
    topicId: '',
    parentId: null,
    likeCount: 0,
    commentCount: 0,
    repostCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    username: '',
    topicName: null,
    parentPost: null,
    isLiked: false,
  );
}
