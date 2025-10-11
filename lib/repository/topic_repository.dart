import 'package:ct312h_project/models/topic.dart';

class TopicRepository {
  Future<List<Topic>> fetchTopics() async {
    // TODO: fetch dữ liệu thật
    await Future.delayed(Duration(milliseconds: 300));
    return [
      Topic(id: 't001', name: "Flutter"),
      Topic(id: 't002', name: "Chat GPT"),
      Topic(id: 't003', name: "Cà phê"),
      Topic(id: 't004', name: "Động vật"),
      Topic(id: 't005', name: "Pet"),
      Topic(id: 't006', name: "IT"),
      Topic(id: 't007', name: "Games"),
      Topic(id: 't008', name: "Music"),
    ];
  }

  Future<List<Topic>> getTopicsByIds(List<String> ids) async {
    final allTopics = await fetchTopics();

    // chỉ giữ lại những Topic có id nằm trong danh sách `ids`
    final filteredTopics = allTopics
        .where((topic) => ids.contains(topic.id))
        .toList();

    return filteredTopics;
  }

  Future<Topic> getTopicById(String id) async {
    // TODO: Sửa logic
    final allTopics = await fetchTopics();
    final filteredTopic = allTopics.firstWhere(
      (topic) => id.contains(topic.id),
    );

    return filteredTopic;
  }
}
