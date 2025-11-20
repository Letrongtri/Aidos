import 'dart:io';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:flutter/material.dart';

class UserService {
  Future<User?> fetchCurrentUser() async {
    try {
      final pb = await getPocketbaseInstance();
      if (!pb.authStore.isValid) return null;

      final record = await pb.collection('users').getOne(pb.authStore.model.id);

      return User(
        id: record.id,
        username: record.data['username'] ?? '',
        email: record.data['email'] ?? '',
        avatarUrl:
            (record.data['avatar'] != null &&
                (record.data['avatar'] as String).isNotEmpty)
            ? "${pb.baseUrl}/api/files/${record.collectionId}/${record.id}/${record.data['avatar']}"
            : null,
        created: DateTime.tryParse(record.created) ?? DateTime.now(),
        updated: DateTime.tryParse(record.updated) ?? DateTime.now(),
        deletedAt: record.data['deletedAt'] != null
            ? DateTime.tryParse(record.data['deletedAt'])
            : null,
      );
    } catch (e) {
      debugPrint('fetchCurrentUser error: $e');
      return null;
    }
  }

  Future<User?> updateUser({
    String? username,
    String? email,
    File? avatarFile,
  }) async {
    try {
      final pb = await getPocketbaseInstance();
      if (!pb.authStore.isValid) throw Exception('User not authenticated');

      final body = <String, dynamic>{};

      if (username != null && username.isNotEmpty) {
        body['username'] = username;
      }
      if (avatarFile != null) {
        body['avatar'] = avatarFile;
      }

      final record = await pb
          .collection('users')
          .update(pb.authStore.model.id, body: body);

      return User(
        id: record.id,
        username: record.data['username'] ?? '',
        email: record.data['email'] ?? '',
        avatarUrl:
            (record.data['avatar'] != null &&
                (record.data['avatar'] as String).isNotEmpty)
            ? "${pb.baseUrl}/api/files/${record.collectionId}/${record.id}/${record.data['avatar']}"
            : null,
        created: DateTime.tryParse(record.created) ?? DateTime.now(),
        updated: DateTime.tryParse(record.updated) ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('updateUser error: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final pb = await getPocketbaseInstance();

    if (!pb.authStore.isValid) throw Exception('User not authenticated');

    try {
      await pb
          .collection('users')
          .update(
            pb.authStore.model.id,
            body: {
              'oldPassword': oldPassword,
              'password': newPassword,
              'passwordConfirm': confirmPassword,
            },
          );

      final email = pb.authStore.model.data['email'] as String;
      await pb.collection('users').authWithPassword(email, newPassword);

      debugPrint("Password updated successfully");
    } catch (e) {
      debugPrint("changePassword error: $e");
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    try {
      final pb = await getPocketbaseInstance();
      if (!pb.authStore.isValid) throw Exception('User not authenticated');

      await pb.collection('users').delete(pb.authStore.model.id);
      pb.authStore.clear();
    } catch (e) {
      debugPrint('deleteUser error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }
}
