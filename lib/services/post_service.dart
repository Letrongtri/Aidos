import 'package:ct312h_project/models/post.dart';

class PostRepository {
  Future<List<Post>> fetchPosts() async {
    // TODO: fetch dữ liệu thật
    await Future.delayed(Duration(milliseconds: 300));
    return [
      Post(
        id: 'p001', // Uuid().v4()
        userId: 'u001',
        content: 'Flutter 3.24 mới có quá nhiều cải tiến! Bạn đã thử chưa?',
        topicId: 't001',
        parentId: '',
        likeCount: 120,
        commentCount: 34,
        repostCount: 12,
        reportCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'p002',
        userId: 'u002',
        content: 'Dart có nên hỗ trợ pattern matching như Swift không nhỉ?',
        topicId: 't002',
        parentId: '',
        likeCount: 87,
        commentCount: 22,
        repostCount: 6,
        reportCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      Post(
        id: 'p003',
        userId: 'u003',
        content:
            'Mình vừa build app đầu tiên với FlutterFlow, nhanh thật sự 😍',
        topicId: 't003',
        parentId: '',
        likeCount: 233,
        commentCount: 58,
        repostCount: 18,
        reportCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
      ),
      Post(
        id: 'p004',
        userId: 'u004',
        content:
            'Có ai đang làm app social với Flutter không? Mình muốn học hỏi thêm 😄',
        topicId: 't004',
        parentId: '',
        likeCount: 55,
        commentCount: 14,
        repostCount: 4,
        reportCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3, hours: 20)),
      ),
      Post(
        id: 'p005',
        userId: 'u001',
        content:
            'Mình thấy Riverpod 3.0 sắp ra bản stable rồi — đáng để chờ đấy!',
        topicId: 't005',
        parentId: '',
        likeCount: 190,
        commentCount: 41,
        repostCount: 9,
        reportCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4, hours: 21)),
      ),
    ];
  }

  Future<Post> getPostById(String id) async {
    // TODO: fetch dữ liệu thật
    final allPosts = await fetchPosts();

    // chỉ giữ lại những post có id nằm trong danh sách `ids`
    final filteredPost = allPosts.firstWhere((post) => id.contains(post.id));

    return filteredPost;
  }

  Future<List<Post>> findPostByKeywords(List<String> queries) async {
    // TODO: join data
    final posts = await fetchPosts();

    return posts.where((p) {
      final content = p.content.toLowerCase();
      return queries.any((q) => content.contains(q));
    }).toList();
  }
}
