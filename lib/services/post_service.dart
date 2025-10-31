import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';

class PostService {
  final List<Post> _posts = [];
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

  // Future<Post> getPostById(String id) async {
  //   // TODO: fetch dữ liệu thật
  //   final allPosts = await fetchPosts();

  //   // chỉ giữ lại những post có id nằm trong danh sách `ids`
  //   final filteredPost = allPosts.firstWhere((post) => id.contains(post.id));

  //   return filteredPost;
  // }

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

    final record = await pb
        .collection('posts')
        .create(
          body: {
            'userId': userId,
            'content': content,
            if (finalTopicId != null) 'topicId': finalTopicId,
          },
        );

    final user = record.expand['userId']?.firstOrNull;
    final topic = record.expand['topicId']?.firstOrNull;

    return Post.fromPocketbase(
      record: record,
      userRecord: user,
      topicRecord: topic,
    );
  }
}
