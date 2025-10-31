import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/user_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final User user;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  EditProfileViewModel({required this.user}) {
    usernameController.text = user.username;
    emailController.text = user.email;
  }

  String? validateBeforeSave() {
    if (usernameController.text.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (emailController.text.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<bool> saveProfile({File? avatar}) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedUser = await _userService.updateUser(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        avatarFile: avatar,
      );

      if (updatedUser != null) {
        isLoading = false;
        notifyListeners();
        return true;
      }
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading = true;
      notifyListeners();
      await _userService.deleteUser();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _userService.logout();
  }
}
