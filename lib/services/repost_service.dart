import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';

class RepostService {
  Future<void> repostPost(String postId, int currentRepostCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final authStore = pb.authStore;

      if (!authStore.isValid) {
        throw Exception('User not authenticated');
      }

      final userId = authStore.model?.id;

      await pb
          .collection('reposts')
          .create(body: {'userId': userId, 'postId': postId});

      await pb
          .collection('posts')
          .update(postId, body: {'reposts': currentRepostCount + 1});
    } catch (e) {
      print('Error reposting: $e');
      rethrow;
    }
  }

  Future<void> unrepostPost(String postId, int currentRepostCount) async {
    try {
      final pb = await getPocketbaseInstance();
      final authStore = pb.authStore;

      if (!authStore.isValid) {
        throw Exception('User not authenticated');
      }

      final userId = authStore.model?.id;

      final result = await pb
          .collection('reposts')
          .getList(filter: 'userId="$userId" && postId="$postId"');

      if (result.items.isNotEmpty) {
        await pb.collection('reposts').delete(result.items.first.id);

        final newCount = (currentRepostCount - 1)
            .clamp(0, double.infinity)
            .toInt();
        await pb
            .collection('posts')
            .update(postId, body: {'reposts': newCount});
      }
    } catch (e) {
      print('Error unreposting: $e');
      rethrow;
    }
  }

  Future<bool> hasUserReposted(String postId) async {
    try {
      final pb = await getPocketbaseInstance();
      final authStore = pb.authStore;

      if (!authStore.isValid) return false;

      final userId = authStore.model?.id;

      final result = await pb
          .collection('reposts')
          .getList(filter: 'userId="$userId" && postId="$postId"', perPage: 1);

      return result.items.isNotEmpty;
    } catch (e) {
      print('Error checking repost status: $e');
      return false;
    }
  }

  Future<Set<String>> fetchRepostedPostIds(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    try {
      final pb = await getPocketbaseInstance();
      final authStore = pb.authStore;

      if (!authStore.isValid) return {};

      final userId = authStore.model?.id;
      final filter =
          'userId="$userId" && (${postIds.map((id) => 'postId="$id"').join(' || ')})';

      final result = await pb
          .collection('reposts')
          .getList(filter: filter, perPage: 500);

      return result.items.map((r) => r.getStringValue('postId')).toSet();
    } catch (e) {
      print('Error fetching reposted posts: $e');
      return {};
    }
  }

  Future<List<String>> fetchUserRepostedPostIds(String userId) async {
    try {
      final pb = await getPocketbaseInstance();

      final result = await pb
          .collection('reposts')
          .getList(filter: 'userId="$userId"', sort: '-created', perPage: 100);

      return result.items.map((r) => r.getStringValue('postId')).toList();
    } catch (e) {
      print('Error fetching user reposts: $e');
      return [];
    }
  }
}
