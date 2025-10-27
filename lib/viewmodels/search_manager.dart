import 'package:ct312h_project/models/topic.dart';
import 'package:ct312h_project/services/post_service.dart';
import 'package:ct312h_project/services/topic_service.dart';
import 'package:ct312h_project/viewmodels/post_item_view_model.dart';
import 'package:ct312h_project/viewmodels/topic_manager.dart';
import 'package:ct312h_project/viewmodels/user_cache_manager.dart';
import 'package:flutter/material.dart';

class SearchManager extends ChangeNotifier {
  final PostRepository postRepo;
  final TopicRepository topicRepo;
  final TopicManager topicManager;
  final UserCacheManager userCache;

  bool isLoading = false;
  String? errorMessage;
  List<PostItemViewModel> searchResults = [];
  List<Topic> topicSuggestions = [];
  String currentQuery = '';

  SearchManager({
    required this.postRepo,
    required this.topicManager,
    required this.userCache,
    required this.topicRepo,
  });

  Future<void> init() async {
    try {
      isLoading = true;
      notifyListeners();

      topicSuggestions = await topicRepo.fetchTopics();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    try {
      isLoading = true;
      notifyListeners();

      if (query.isEmpty) {
        searchResults = [];
        notifyListeners();
        return;
      }

      final currentQuery = query.trim().toLowerCase();
      final keywords = currentQuery.split(RegExp(r'\s+'));

      final posts = await postRepo.findPostByKeywords(keywords);

      if (posts.isEmpty) {
        searchResults = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final userIds = posts.map((p) => p.userId).toSet().toList();
      final topicIds = posts.map((p) => p.topicId).toSet().toList();

      // for (var post in posts) {
      //   userIds.add(post.userId);

      //   // if (post.topicId.isNotEmpty) {
      //   //   topicIds.add(post.topicId);
      //   // }
      // }

      await Future.wait([
        // lấy Topic name (nếu có)
        if (topicIds.isNotEmpty) topicManager.preloadTopics(topicIds),
        // Lấy danh sách userId duy nhất từ các post
        if (userIds.isNotEmpty) userCache.preloadUsers(userIds),
      ]);

      // Gộp lại: post + username + topicname
      searchResults = posts
          .map((post) {
            final user = userCache.tryGetCached(post.userId);
            final topic = post.topicId.isNotEmpty
                ? topicManager.tryGetCached(post.topicId)
                : null;

            if (user == null) {
              debugPrint("Missing user ${post.userId} in cache");
              return null;
            }

            return PostItemViewModel.fromEntites(
              post: post,
              user: user,
              topic: topic,
            );
          })
          .where((vm) => vm != null)
          .cast<PostItemViewModel>()
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> search(String query) async {
  //   if (isLoading) return;

  //   try {
  //     isLoading = true;
  //     errorMessage = null;
  //     notifyListeners();

  //     final posts = await postRepo.fetchPosts();

  //     final topicIds = <String>[];
  //     final userIds = <String>[];

  //     for (var post in posts) {
  //       userIds.add(post.userId);

  //       if (post.topicId.isNotEmpty == true) {
  //         topicIds.add(post.topicId);
  //       }
  //     }

  //     await Future.wait([
  //       // lấy Topic name (nếu có)
  //       if (topicIds.isNotEmpty) topicManager.preloadTopics(topicIds.toList()),
  //       // Lấy danh sách userId duy nhất từ các post
  //       if (userIds.isNotEmpty) userCache.preloadUsers(userIds.toList()),
  //     ]);

  //     // Gộp lại: post + username + topicname
  //     searchResults = posts.map((post) {
  //       final user = userCache.tryGetCached(post.userId);

  //       if (user == null) {
  //         throw Exception("Missing user ${post.userId} in cache");
  //       }

  //       final topic = post.topicId.isNotEmpty
  //           ? topicManager.tryGetCached(post.topicId)
  //           : null;

  //       return PostItemViewModel.fromEntites(
  //         post: post,
  //         user: user,
  //         topic: topic,
  //       );
  //     }).toList();

  //     print(searchResults);
  //   } catch (e) {
  //     errorMessage = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
