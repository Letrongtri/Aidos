import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
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

  // Future<Post> getPostById(String id) async {
  //   // TODO: fetch dữ liệu thật
  //   final allPosts = await fetchPosts();

  //   // chỉ giữ lại những post có id nằm trong danh sách `ids`
  //   final filteredPost = allPosts.firstWhere((post) => id.contains(post.id));

  //   return filteredPost;
  // }

  Future<List<Post>> findPostByKeywords(List<String> queries) async {
    // TODO: join data
    final posts = await fetchPosts();

    return posts.where((p) {
      final content = p.content.toLowerCase();
      return queries.any((q) => content.contains(q));
    }).toList();
  }
}
