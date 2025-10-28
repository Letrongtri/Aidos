import 'package:ct312h_project/services/pocketbase_client.dart';

class LikeService {
  Future<Set<String>> fetchLikedPostIds(List<String> postIds) async {
    Set<String> likedPostIds = {};
    if (postIds.isEmpty) return {};
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;
      final idsString = postIds.join("' || postId~'");
      final filter = "userId = '$userId' && (postId~'$idsString')";

      final result = await pb
          .collection('likes')
          .getFullList(filter: filter, fields: 'postId');

      likedPostIds = result
          .map((record) => record.getStringValue('postId'))
          .toSet();

      return likedPostIds;
    } catch (e) {
      return likedPostIds;
    }
  }
}
