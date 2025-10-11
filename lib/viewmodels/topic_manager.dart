import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/repository/topic_repository.dart';
import 'package:flutter/material.dart';

class TopicManager extends ChangeNotifier {
  final TopicRepository topicRepo;
  final Map<String, Topic> _cache = {};

  TopicManager({required this.topicRepo});

  bool isLoading = false;
  String? errorMessage;

  int get topicCount {
    return _cache.length;
  }

  List<Topic> get topics {
    return _cache.values.toList();
  }

  Future<Topic> getTopicById(String topicId) async {
    if (_cache.containsKey(topicId)) return _cache[topicId]!;

    final topic = await topicRepo.getTopicById(topicId);

    _cache[topicId] = topic;
    return topic;
  }

  Future<void> preloadTopics(List<String> ids) async {
    final missing = ids.where((id) => !_cache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    final users = await topicRepo.getTopicsByIds(missing);
    for (final u in users) {
      _cache[u.id] = u;
    }
  }

  Topic? tryGetCached(String id) => _cache[id];

  void clear() => _cache.clear();

  Future<void> fetchTopics() async {
    if (isLoading) return;

    // TODO: thay đổi logic fetch
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final topics = await topicRepo.fetchTopics();

      for (var topic in topics) {
        if (!_cache.containsKey(topic.id)) {
          _cache[topic.id] = topic;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
