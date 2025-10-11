import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/repository/user_repository.dart';

class UserCacheManager {
  final UserRepository userRepo;
  final Map<String, User> _cache = {};

  UserCacheManager({required this.userRepo});

  Future<User> getUser(String userId) async {
    if (_cache.containsKey(userId)) return _cache[userId]!;

    final user = await userRepo.getUsersById(userId);
    _cache[userId] = user;
    return user;
  }

  Future<void> preloadUsers(List<String> ids) async {
    final missing = ids.where((id) => !_cache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    final users = await userRepo.getUsersByIds(missing);
    for (final u in users) {
      _cache[u.id] = u;
    }
  }

  User? tryGetCached(String id) => _cache[id];

  void clear() => _cache.clear();
}
