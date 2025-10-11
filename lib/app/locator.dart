import 'package:ct312h_project/repository/comment_repository.dart';
import 'package:ct312h_project/repository/post_repository.dart';
import 'package:ct312h_project/repository/topic_repository.dart';
import 'package:ct312h_project/repository/user_repository.dart';

import 'package:ct312h_project/viewmodels/comment_manager.dart';
import 'package:ct312h_project/viewmodels/detail_post_manager.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:ct312h_project/viewmodels/search_manager.dart';
import 'package:ct312h_project/viewmodels/topic_manager.dart';
import 'package:ct312h_project/viewmodels/user_cache_manager.dart';

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Repository layer
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<PostRepository>(() => PostRepository());
  getIt.registerLazySingleton<CommentRepository>(() => CommentRepository());
  getIt.registerLazySingleton<TopicRepository>(() => TopicRepository());

  // Shared managers
  getIt.registerLazySingleton<UserCacheManager>(
    () => UserCacheManager(userRepo: getIt<UserRepository>()),
  );
  getIt.registerLazySingleton(
    () => TopicManager(topicRepo: getIt<TopicRepository>()),
  );

  // View Models
  getIt.registerLazySingleton<PostsManager>(
    () => PostsManager(
      postRepo: getIt<PostRepository>(),
      userCache: getIt<UserCacheManager>(),
      topicCache: getIt<TopicManager>(),
    ),
  );
  getIt.registerLazySingleton<SearchManager>(
    () => SearchManager(
      postRepo: getIt<PostRepository>(),
      topicRepo: getIt<TopicRepository>(),
      topicManager: getIt<TopicManager>(),
      userCache: getIt<UserCacheManager>(),
    ),
  );
  getIt.registerFactory<CommentManager>(
    () => CommentManager(
      commentRepo: getIt<CommentRepository>(),
      userCache: getIt<UserCacheManager>(),
    ),
  );
  getIt.registerFactory<DetailPostManager>(
    () => DetailPostManager(
      postRepo: getIt<PostRepository>(),
      userCache: getIt<UserCacheManager>(),
      commentManager: getIt<CommentManager>(),
    ),
  );
}
