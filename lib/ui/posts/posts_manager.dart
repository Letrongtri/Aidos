import 'package:ct312h_project/models/post.dart';
// import 'package:uuid/uuid.dart';

class PostsManager {
  final List<Post> _posts = [
    Post(
      id: 'p001', // Uuid().v4()
      userId: 'u001',
      content: 'Flutter 3.24 mới có quá nhiều cải tiến! Bạn đã thử chưa?',
      topicId: 'topic_flutter',
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
      topicId: 'topic_dart',
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
      content: 'Mình vừa build app đầu tiên với FlutterFlow, nhanh thật sự 😍',
      topicId: 'topic_tools',
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
      topicId: 'topic_community',
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
      userId: 'u005',
      content:
          'Mình thấy Riverpod 3.0 sắp ra bản stable rồi — đáng để chờ đấy!',
      topicId: 'topic_state_management',
      parentId: '',
      likeCount: 190,
      commentCount: 41,
      repostCount: 9,
      reportCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4, hours: 21)),
    ),
  ];

  int get postCount {
    return _posts.length;
  }

  List<Post> get posts {
    return [..._posts];
  }
}
