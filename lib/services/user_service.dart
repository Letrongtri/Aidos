import 'dart:math';
import 'package:ct312h_project/models/user.dart';

class UserRepository {
  // 🔹 Giả lập API delay
  Future<List<User>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      User(
        id: 'u001',
        username: 'nguyenvana',
        email: 'nguyenvana@example.com',
        avatarUrl: _randomAvatar(),
        password: 'hashedpassword123',
        createdAt: DateTime(2024, 3, 15),
        updatedAt: DateTime(2024, 5, 10),
        deletedAt: null,
      ),
      User(
        id: 'u002',
        username: 'tranthib',
        email: 'tranthib@example.com',
        avatarUrl: _randomAvatar(),
        password: 'securePass456',
        createdAt: DateTime(2024, 6, 2),
        updatedAt: DateTime(2024, 8, 20),
        deletedAt: null,
      ),
      User(
        id: 'u003',
        username: 'leminhc',
        email: 'leminhc@example.com',
        avatarUrl: _randomAvatar(),
        password: 'encrypted789',
        createdAt: DateTime(2024, 1, 25),
        updatedAt: DateTime(2025, 1, 1),
        deletedAt: null,
      ),
      User(
        id: 'u004',
        username: 'phamquangd',
        email: 'phamquangd@example.com',
        avatarUrl: _randomAvatar(),
        password: 'supersecurepass',
        createdAt: DateTime(2023, 12, 10),
        updatedAt: DateTime(2025, 3, 12),
        deletedAt: DateTime(2025, 5, 1),
      ),
    ];
  }

  // 🔹 Lấy user hiện tại (ví dụ: user đang đăng nhập)
  Future<User?> fetchCurrentUser() async {
    final allUsers = await fetchUsers();
    return allUsers.isNotEmpty ? allUsers.first : null;
  }

  // 🔹 Lấy danh sách user theo ID
  Future<List<User>> getUsersByIds(List<String> ids) async {
    final allUsers = await fetchUsers();
    return allUsers.where((user) => ids.contains(user.id)).toList();
  }

  // 🔹 Lấy 1 user theo ID
  Future<User?> getUserById(String id) async {
    final allUsers = await fetchUsers();
    try {
      return allUsers.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // 🔹 Xóa user (giả lập)
  Future<void> deleteUser(String userId) async {
    print('Đang xóa user $userId...');
    await Future.delayed(const Duration(seconds: 2));
    print('User $userId đã bị xóa.');
  }

  // 🔹 Đăng xuất (giả lập)
  Future<void> logout() async {
    print('Đang đăng xuất...');
    await Future.delayed(const Duration(seconds: 1));
    print('Đã đăng xuất thành công.');
  }

  // 🔹 Hàm random avatar (API miễn phí)
  static String _randomAvatar() {
    final random = Random();
    final seed = random.nextInt(10000);
    return 'https://api.dicebear.com/9.x/pixel-art/svg?seed=$seed';
  }
}
