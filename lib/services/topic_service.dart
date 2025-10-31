import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';

class TopicService {
  Future<List<Topic>> fetchTopics({int page = 1, int perPage = 500}) async {
    List<Topic> topics = [];
    try {
      final pb = await getPocketbaseInstance();

      final result = await pb
          .collection('topics')
          .getList(page: page, perPage: perPage, sort: '-created');

      topics = result.items.map((record) {
        return Topic.fromPocketbase(record);
      }).toList();
      return topics;
    } catch (e) {
      return topics;
    }
  }
}
