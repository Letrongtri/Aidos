import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:flutter/material.dart';

class LikeService {
  Future<Set<String>> fetchLikedPostIds(List<String> postIds) async {
    Set<String> likedPostIds = {};
    if (postIds.isEmpty) return {};
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final idsString = postIds.join("' || postId~'");
      final filter = "userId = '$userId' && (postId~'$idsString')";

      final result = await pb
          .collection('likes')
          .getFullList(filter: filter, fields: 'postId');

      likedPostIds = result
          .map((record) => record.getStringValue('postId'))
          .toSet();

      return likedPostIds;
    } catch (e) {
      return likedPostIds;
    }
  }

  Future<Set<String>> fetchLikedCommentIds(List<String> commentIds) async {
    Set<String> likedCommentIds = {};
    if (commentIds.isEmpty) return {};
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final idsString = commentIds.join("' || commentId~'");
      final filter = "userId = '$userId' && (commentId~'$idsString')";

      final result = await pb
          .collection('likes')
          .getFullList(filter: filter, fields: 'commentId');

      likedCommentIds = result
          .map((record) => record.getStringValue('commentId'))
          .toSet();

      return likedCommentIds;
    } catch (e) {
      return likedCommentIds;
    }
  }

  Future<void> likePost(String postId, int likeCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      await pb
          .collection('likes')
          .create(body: {'postId': postId, 'userId': userId});

      await Future.delayed(Duration(milliseconds: 100));

      final likesResult = await pb
          .collection('likes')
          .getList(filter: 'postId = "$postId"', perPage: 500);

      final totalLikes = likesResult.items.length;

      await pb.collection('posts').update(postId, body: {'likes': totalLikes});
    } catch (e) {
      debugPrint('likePost error: $e');
      throw Exception();
    }
  }

  Future<void> unlikePost(String postId, int likeCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      final likes = await pb
          .collection('likes')
          .getList(
            filter: 'postId = "$postId" && userId = "$userId"',
            perPage: 1,
          );

      if (likes.items.isEmpty) {
        throw Exception("Cannot get like to delete");
      }

      final likeId = likes.items.first.id;
      await pb.collection('likes').delete(likeId);

      await Future.delayed(Duration(milliseconds: 100));

      final likesResult = await pb
          .collection('likes')
          .getList(filter: 'postId = "$postId"', perPage: 500);

      final totalLikes = likesResult.items.length;

      await pb.collection('posts').update(postId, body: {'likes': totalLikes});
    } catch (e) {
      debugPrint('unlikePost error: $e');
      throw Exception();
    }
  }

  Future<void> likeComment(String commentId, int likeCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      await pb
          .collection('likes')
          .create(body: {'commentId': commentId, 'userId': userId});
      final likesResult = await pb
          .collection('likes')
          .getList(filter: 'commentId = "$commentId"', perPage: 500);

      final totalLikes = likesResult.items.length;

      await pb
          .collection('comments')
          .update(commentId, body: {'likes': totalLikes});
    } catch (e) {
      debugPrint(e.toString());
      throw Exception();
    }
  }

  Future<void> unlikeComment(String commentId, int likeCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      final likes = await pb
          .collection('likes')
          .getList(
            filter: 'commentId = "$commentId" && userId = "$userId"',
            perPage: 1,
          );

      if (likes.items.isEmpty) {
        throw Exception("Cannot get like to delete");
      }

      final likeId = likes.items.first.id;
      await pb.collection('likes').delete(likeId);

      final likesResult = await pb
          .collection('likes')
          .getList(filter: 'commentId = "$commentId"', perPage: 500);

      final totalLikes = likesResult.items.length;
      await pb
          .collection('comments')
          .update(commentId, body: {'likes': totalLikes});
    } catch (e) {
      debugPrint(e.toString());
      throw Exception();
    }
  }
}
