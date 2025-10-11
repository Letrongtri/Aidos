import 'package:ct312h_project/models/user.dart';

class UserRepository {
  Future<List<User>> fetchUser() async {
    // TODO: fetch dữ liệu thật
    await Future.delayed(Duration(milliseconds: 300));
    return [
      User(
        id: 'u001',
        username: 'nguyenvana',
        email: 'nguyenvana@example.com',
        password: 'hashedpassword123',
        bio: 'Yêu công nghệ, thích code Flutter.',
        createdAt: DateTime(2024, 3, 15),
        updatedAt: DateTime(2024, 5, 10),
        deletedAt: null,
        isblock: false,
      ),
      User(
        id: 'u002',
        username: 'tranthib',
        email: 'tranthib@example.com',
        password: 'securePass456',
        bio: 'Front-end dev, thích UI tinh tế.',
        createdAt: DateTime(2024, 6, 2),
        updatedAt: DateTime(2024, 8, 20),
        deletedAt: null,
        isblock: false,
      ),
      User(
        id: 'u003',
        username: 'leminhc',
        email: 'leminhc@example.com',
        password: 'encrypted789',
        bio: 'Back-end engineer, ghét bug.',
        createdAt: DateTime(2024, 1, 25),
        updatedAt: DateTime(2025, 1, 1),
        deletedAt: null,
        isblock: true,
      ),
      User(
        id: 'u004',
        username: 'phamquangd',
        email: 'phamquangd@example.com',
        password: 'supersecurepass',
        bio: 'DevOps, thích tự động hóa mọi thứ.',
        createdAt: DateTime(2023, 12, 10),
        updatedAt: DateTime(2025, 3, 12),
        deletedAt: DateTime(2025, 5, 1),
        isblock: true,
      ),
    ];
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    final allUsers = await fetchUser();

    // chỉ giữ lại những user có id nằm trong danh sách `ids`
    final filteredUsers = allUsers
        .where((user) => ids.contains(user.id))
        .toList();

    return filteredUsers;
  }

  Future<User> getUsersById(String id) async {
    final allUsers = await fetchUser();

    // chỉ giữ lại những user có id nằm trong danh sách `ids`
    final filteredUser = allUsers.firstWhere((user) => id.contains(user.id));

    return filteredUser;
  }
}
