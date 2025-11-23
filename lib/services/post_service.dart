import 'dart:async';

import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:flutter/foundation.dart'; // Cần thiết để dùng kIsWeb
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';

class PostService {
  Future<List<Post>> fetchPosts({int page = 1, int perPage = 10}) async {
    List<Post> posts = [];
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId,topicId';

      final result = await pb
          .collection('posts')
          .getList(
            page: page,
            perPage: perPage,
            sort: '-created',
            expand: expandFields,
          );

      posts = result.items.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        final topic = record.get<RecordModel>('expand.topicId');
        return Post.fromPocketbase(
          record: record,
          userRecord: user,
          topicRecord: topic,
        );
      }).toList();

      return posts;
    } catch (e) {
      return posts;
    }
  }

  Future<List<Post>> fetchTrendingPosts({
    int page = 1,
    int perPage = 10,
  }) async {
    List<Post> posts = [];
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId,topicId';

      final result = await pb
          .collection('posts')
          .getList(
            page: page,
            perPage: perPage,
            sort: '-likes,-comments,-reposts,-created',
            expand: expandFields,
          );

      posts = result.items.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        final topic = record.get<RecordModel>('expand.topicId');
        return Post.fromPocketbase(
          record: record,
          userRecord: user,
          topicRecord: topic,
        );
      }).toList();

      return posts;
    } catch (e) {
      return posts;
    }
  }

  Future<List<Post>> findPostByKeywords(
    List<String> queries, {
    int page = 1,
    int perPage = 30,
  }) async {
    List<Post> posts = [];
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId,topicId,posts_via_topicId';

      final filter = queries.isEmpty
          ? ''
          : '(${queries.map((q) => '(content ?~ "${q.trim()}" || topicId.name ?~ "${q.trim()}")').join(' || ')})';

      final result = await pb
          .collection('posts')
          .getList(
            page: page,
            perPage: perPage,
            filter: filter,
            expand: expandFields,
            sort: '-created',
          );

      posts = result.items.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        final topic = record.get<RecordModel>('expand.topicId');
        return Post.fromPocketbase(
          record: record,
          userRecord: user,
          topicRecord: topic,
        );
      }).toList();

      return posts;
    } catch (e) {
      return posts;
    }
  }

  Future<Post> createPostWithTopicName({
    required String userId,
    required String content,
    String? topicName,
    List<XFile>? images,
  }) async {
    try {
      final pb = await getPocketbaseInstance();
      String? finalTopicId;

      if (topicName != null && topicName.trim().isNotEmpty) {
        final result = await pb
            .collection('topics')
            .getList(
              perPage: 1,
              filter:
                  'name = "${topicName.toLowerCase().replaceAll('"', '\\"')}"',
            );

        if (result.items.isNotEmpty) {
          finalTopicId = result.items.first.id;
        } else {
          final newTopic = await pb
              .collection('topics')
              .create(body: {'name': topicName});
          finalTopicId = newTopic.id;
        }
      }

      // --- FIX: Xử lý ảnh cho Web và Mobile ---
      List<http.MultipartFile> fileList = [];
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          if (kIsWeb) {
            // Web: Đọc bytes
            final bytes = await image.readAsBytes();
            fileList.add(
              http.MultipartFile.fromBytes(
                'images',
                bytes,
                filename: image.name,
              ),
            );
          } else {
            // Mobile: Đọc từ path
            fileList.add(
              await http.MultipartFile.fromPath('images', image.path),
            );
          }
        }
      }
      // ----------------------------------------

      final record = await pb
          .collection('posts')
          .create(
            body: {
              'userId': userId,
              'content': content,
              if (finalTopicId != null) 'topicId': finalTopicId,
            },
            files: fileList,
            expand: 'userId,topicId,posts_via_topicId',
          );

      final user = record.expand['userId']?.firstOrNull;
      final topic = record.expand['topicId']?.firstOrNull;

      return Post.fromPocketbase(
        record: record,
        userRecord: user,
        topicRecord: topic,
      );
    } catch (e, st) {
      debugPrint('createPostWithTopicName ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<List<Post>> fetchPostsByUser(String userId) async {
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId,topicId';
      final result = await pb
          .collection('posts')
          .getList(
            filter: 'userId="$userId"',
            sort: '-created',
            expand: expandFields,
          );

      return result.items.map((record) {
        final user = record.get<RecordModel>('expand.userId');
        final topic = record.get<RecordModel>('expand.topicId');
        return Post.fromPocketbase(
          record: record,
          userRecord: user,
          topicRecord: topic,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchRepliedPosts(String userId) async {
    try {
      final pb = await getPocketbaseInstance();

      final comments = await pb
          .collection('comments')
          .getList(
            page: 1,
            perPage: 30,
            filter: 'userId="$userId"',
            expand: 'postId,postId.userId,postId.topicId',
            sort: '-created',
          );

      final replied = comments.items
          .map((c) {
            final postRecord = c.expand['postId']?.firstOrNull;
            if (postRecord == null) return null;

            final user = c.expand['postId.userId']?.firstOrNull;
            final topic = c.expand['postId.topicId']?.firstOrNull;

            final post = Post.fromPocketbase(
              record: postRecord,
              userRecord: user,
              topicRecord: topic,
            );

            return {'post': post, 'comment': c.getStringValue('content')};
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      return replied;
    } catch (e, st) {
      debugPrint('Error fetching replied posts: $e\n$st');
      return [];
    }
  }

  Future<Post> updatePost({
    required String postId,
    required String content,
    String? topicName,
    List<XFile>? images,
  }) async {
    final pb = await getPocketbaseInstance();
    String? finalTopicId;

    if (topicName != null && topicName.isNotEmpty) {
      final result = await pb
          .collection('topics')
          .getList(perPage: 1, filter: 'name="$topicName"');

      if (result.items.isNotEmpty) {
        finalTopicId = result.items.first.id;
      } else {
        final newTopic = await pb
            .collection('topics')
            .create(body: {'name': topicName});
        finalTopicId = newTopic.id;
      }
    }

    // --- FIX: Xử lý ảnh cho Web và Mobile ---
    List<http.MultipartFile> fileList = [];
    if (images != null && images.isNotEmpty) {
      for (var image in images) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          fileList.add(
            http.MultipartFile.fromBytes('images', bytes, filename: image.name),
          );
        } else {
          fileList.add(await http.MultipartFile.fromPath('images', image.path));
        }
      }
    }
    // ----------------------------------------

    final record = await pb
        .collection('posts')
        .update(
          postId,
          body: {
            'content': content,
            if (finalTopicId != null) 'topicId': finalTopicId,
          },
          files: fileList,
          expand: 'userId,topicId',
        );

    final user = record.expand['userId']?.firstOrNull;
    final topic = record.expand['topicId']?.firstOrNull;

    return Post.fromPocketbase(
      record: record,
      userRecord: user,
      topicRecord: topic,
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('posts').delete(postId);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<Post?> fetchPostById(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      final expandFields = 'userId,topicId';

      final record = await pb
          .collection('posts')
          .getOne(id, expand: expandFields);

      final user = record.get<RecordModel>('expand.userId');
      final topic = record.get<RecordModel>('expand.topicId');

      return Post.fromPocketbase(
        record: record,
        userRecord: user,
        topicRecord: topic,
      );
    } on ClientException catch (e) {
      if (e.statusCode == 404) return null;
      debugPrint('Error fetching single post by ID: $e');
      return null;
    } catch (e) {
      debugPrint('Error fetching single post by ID: $e');
      return null;
    }
  }

  Stream<RecordSubscriptionEvent> subscribeToPost() {
    // Tạo controller
    final controller = StreamController<RecordSubscriptionEvent>();

    // Biến để lưu hàm unsubscribe
    UnsubscribeFunc? unsubscribeFunc;

    // Bắt đầu logic khởi tạo bất đồng bộ
    getPocketbaseInstance().then((pb) {
      pb
          .collection('posts')
          .subscribe('*', (e) {
            if (!controller.isClosed) {
              controller.add(e);
            }
          })
          .then((func) {
            unsubscribeFunc = func;
          })
          .catchError((err) {
            if (!controller.isClosed) controller.addError(err);
          });
    });

    // Dọn dẹp khi không lắng nghe nữa
    controller.onCancel = () async {
      if (unsubscribeFunc != null) {
        await unsubscribeFunc!();
      }
      await controller.close();
    };

    return controller.stream;
  }
}
