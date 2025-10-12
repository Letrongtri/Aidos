import 'package:ct312h_project/models/user.dart';

class UserRepository {
  Future<List<User>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      User(
        id: 'u001',
        name: 'Nguyễn Văn A',
        username: 'nguyenvana',
        email: 'nguyenvana@example.com',
        password: 'hashedpassword123',
        bio: 'Yêu công nghệ, thích code Flutter.',
        link: 'Ngvan@fb.com',
        avatarUrl: 'assets/images/logo.png',
        followerCount: 152,
        createdAt: DateTime(2024, 3, 15),
        updatedAt: DateTime(2024, 5, 10),
        deletedAt: null,
        isblock: false,
        isPrivate: false,
      ),
      User(
        id: 'u002',
        name: 'Trần Thị B',
        username: 'tranthib',
        email: 'tranthib@example.com',
        password: 'securePass456',
        bio: 'Front-end dev, thích UI tinh tế.',
        link: 'Nvb@yahoo.com',
        avatarUrl: 'assets/images/avatar2.png',
        followerCount: 2048,
        createdAt: DateTime(2024, 6, 2),
        updatedAt: DateTime(2024, 8, 20),
        deletedAt: null,
        isblock: false,
        isPrivate: false,
      ),
      User(
        id: 'u003',
        name: 'Lê Minh C',
        username: 'leminhc',
        email: 'leminhc@example.com',
        password: 'encrypted789',
        bio: 'Back-end engineer, ghét bug.',
        link: 'leminhc@gmail.com',
        avatarUrl: 'assets/images/avatar3.png',
        followerCount: 768,
        createdAt: DateTime(2024, 1, 25),
        updatedAt: DateTime(2025, 1, 1),
        deletedAt: null,
        isblock: true,
        isPrivate: false,
      ),
      User(
        id: 'u004',
        name: 'Phạm Quang D',
        username: 'phamquangd',
        email: 'phamquangd@example.com',
        password: 'supersecurepass',
        bio: 'DevOps, thích tự động hóa mọi thứ.',
        link: 'thisqd@gmail.com',
        avatarUrl: 'assets/images/avatar4.png',
        followerCount: 1200,
        createdAt: DateTime(2023, 12, 10),
        updatedAt: DateTime(2025, 3, 12),
        deletedAt: DateTime(2025, 5, 1),
        isblock: true,
        isPrivate: false,
      ),
    ];
  }

  Future<User?> fetchCurrentUser() async {
    final allUsers = await fetchUsers();
    if (allUsers.isNotEmpty) {
      return allUsers.first;
    }
    return null;
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    final allUsers = await fetchUsers();
    final filteredUsers = allUsers
        .where((user) => ids.contains(user.id))
        .toList();
    return filteredUsers;
  }

  Future<User?> getUserById(String id) async {
    final allUsers = await fetchUsers();
    try {
      final filteredUser = allUsers.firstWhere((user) => user.id == id);
      return filteredUser;
    } catch (e) {
      return null;
    }
  }

  Future<User> updateUserProfile(
    String userId,
    String newBio,
    bool isPrivate,
  ) async {
    print(
      'Updating user $userId with bio: "$newBio" and private status: $isPrivate',
    );
    await Future.delayed(const Duration(seconds: 1));

    final currentUser = await getUserById(userId);
    if (currentUser != null) {
      return currentUser.copyWith(bio: newBio);
    }
    throw Exception('User not found during update');
  }

  Future<void> deleteUser(String userId) async {
    print('Deleting user $userId...');
    await Future.delayed(const Duration(seconds: 2));
    print('User $userId deleted successfully.');
  }

  Future<void> logout() async {
    print('Đang đăng xuất...');
    await Future.delayed(const Duration(seconds: 1));
    print('Đã đăng xuất thành công.');
  }
}
