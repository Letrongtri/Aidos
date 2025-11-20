import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/services/services.dart';
import 'package:flutter/material.dart';

class SearchManager extends ChangeNotifier {
  final _postService = PostService();
  final _topicService = TopicService();

  String? errorMessage;
  List<Post> searchResults = [];
  List<Topic> topicSuggestions = [];
  String currentQuery = '';

  List<Post> get posts => [...searchResults];
  int get postCount => searchResults.length;

  List<Topic> get topic => [...topicSuggestions];
  int get topicCount => topicSuggestions.length;

  Future<void> fetchSuggestionTopics() async {
    try {
      topicSuggestions = await _topicService.fetchTopics();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<List<Post>> fetchTrendingPosts() async {
    List<Post> posts = [];
    try {
      posts = await _postService.fetchPosts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
    return posts;
  }

  Future<void> search(String? query) async {
    try {
      if (query == null || query.isEmpty) {
        searchResults = await fetchTrendingPosts();
        notifyListeners();
        return;
      }

      final currentQuery = query.trim().toLowerCase();
      final keywords = currentQuery.split(RegExp(r'\s+'));

      final posts = await _postService.findPostByKeywords(keywords);

      if (posts.isEmpty) {
        searchResults = [];
        notifyListeners();
        return;
      }

      searchResults = posts;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
