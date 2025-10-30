// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:ct312h_project/models/comment.dart';
// import 'package:ct312h_project/models/user.dart';

// class CommentItemViewModel {
//   final String id;
//   final String postId;
//   final String userId;
//   final String content;
//   final String? parentId;
//   final int likeCount;
//   final int replyCount;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   final String username;
//   final bool isLiked;

//   CommentItemViewModel({
//     required this.id,
//     required this.postId,
//     required this.userId,
//     required this.content,
//     this.parentId,
//     required this.likeCount,
//     required this.replyCount,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.username,
//     this.isLiked = false,
//   });

//   CommentItemViewModel copyWith({
//     String? id,
//     String? postId,
//     String? userId,
//     String? content,
//     String? parentId,
//     int? likeCount,
//     int? replyCount,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     String? username,
//     bool? isLiked,
//   }) {
//     return CommentItemViewModel(
//       id: id ?? this.id,
//       postId: postId ?? this.postId,
//       userId: userId ?? this.userId,
//       content: content ?? this.content,
//       parentId: parentId ?? this.parentId,
//       likeCount: likeCount ?? this.likeCount,
//       replyCount: replyCount ?? this.replyCount,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       username: username ?? this.username,
//       isLiked: isLiked ?? this.isLiked,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'postId': postId,
//       'userId': userId,
//       'content': content,
//       'parentId': parentId,
//       'likeCount': likeCount,
//       'replyCount': replyCount,
//       'createdAt': createdAt.millisecondsSinceEpoch,
//       'updatedAt': updatedAt.millisecondsSinceEpoch,
//       'username': username,
//       'isLiked': isLiked,
//     };
//   }

//   factory CommentItemViewModel.fromMap(Map<String, dynamic> map) {
//     return CommentItemViewModel(
//       id: map['id'] as String,
//       postId: map['postId'] as String,
//       userId: map['userId'] as String,
//       content: map['content'] as String,
//       parentId: map['parentId'] != null ? map['parentId'] as String : null,
//       likeCount: map['likeCount'] as int,
//       replyCount: map['replyCount'] as int,
//       createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
//       updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
//       username: map['username'] as String,
//       isLiked: map['isLiked'] as bool,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory CommentItemViewModel.fromJson(String source) =>
//       CommentItemViewModel.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() {
//     return 'CommentItemViewModel(id: $id, postId: $postId, userId: $userId, content: $content, parentId: $parentId, likeCount: $likeCount, replyCount: $replyCount, createdAt: $createdAt, updatedAt: $updatedAt, username: $username, isLiked: $isLiked)';
//   }

//   @override
//   bool operator ==(covariant CommentItemViewModel other) {
//     if (identical(this, other)) return true;

//     return other.id == id &&
//         other.postId == postId &&
//         other.userId == userId &&
//         other.content == content &&
//         other.parentId == parentId &&
//         other.likeCount == likeCount &&
//         other.replyCount == replyCount &&
//         other.createdAt == createdAt &&
//         other.updatedAt == updatedAt &&
//         other.username == username &&
//         other.isLiked == isLiked;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         postId.hashCode ^
//         userId.hashCode ^
//         content.hashCode ^
//         parentId.hashCode ^
//         likeCount.hashCode ^
//         replyCount.hashCode ^
//         createdAt.hashCode ^
//         updatedAt.hashCode ^
//         username.hashCode ^
//         isLiked.hashCode;
//   }

//   factory CommentItemViewModel.fromEntites({
//     required Comment comment,
//     required User user,
//     bool? isLiked,
//   }) {
//     return CommentItemViewModel(
//       id: comment.id,
//       postId: comment.postId,
//       userId: comment.userId,
//       content: comment.content,
//       likeCount: comment.likeCount,
//       replyCount: comment.replyCount,
//       createdAt: comment.createdAt,
//       updatedAt: comment.updatedAt,
//       username: user.username,
//       parentId: comment.parentId,
//       isLiked: isLiked ?? false,
//     );
//   }

//   factory CommentItemViewModel.empty() => CommentItemViewModel(
//     id: '',
//     postId: '',
//     userId: '',
//     content: '',
//     parentId: null,
//     likeCount: 0,
//     replyCount: 0,
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     username: '',
//   );
// }
