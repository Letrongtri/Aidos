import 'dart:io';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/services.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileManager extends ChangeNotifier {
  final PanelController panelController = PanelController();
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  bool isLoading = false;
  User? user;
  AuthManager? _authManager;

  bool _isRepliesLoading = false;
  bool get isRepliesLoading => _isRepliesLoading;

  List<Map<String, dynamic>> _repliedPosts = [];
  List<Map<String, dynamic>> get repliedPosts => _repliedPosts;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void updateAuthUser(AuthManager auth) {
    _authManager = auth;

    // if (auth.user != null) {
    //   for (int i = 0; i < _repliedPosts.length; i++) {
    //     final post = _repliedPosts[i];
    //     if (post.userId == auth.user!.id) {
    //       _repliedPosts[i] = post.copyWith(user: auth.user);
    //     }
    //   }
    // }
    user = auth.user;
    notifyListeners();
  }

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedUser = _authManager?.user;

      if (fetchedUser != null) {
        usernameController.text = user?.username ?? '';
        emailController.text = user?.email ?? '';

        await fetchMyReplies();
      }
    } catch (e) {
      debugPrint("loadUser error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyReplies() async {
    if (user == null) return;

    _isRepliesLoading = true;
    notifyListeners();
    try {
      _repliedPosts = await _postService.fetchRepliedPosts(user!.id);
    } catch (e) {
      debugPrint("fetchMyReplies error: $e");
      _repliedPosts = [];
    } finally {
      _isRepliesLoading = false;
      notifyListeners();
    }
  }

  String? validateBeforeSave() {
    if (usernameController.text.trim().isEmpty) {
      return "Username cannot be empty";
    }
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<bool> saveProfile({
    File? avatarFile,
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedUser = await _userService.updateUser(
        username: usernameController.text.trim(),
        avatarFile: avatarFile,
      );
      if (newPassword != null &&
          newPassword.isNotEmpty &&
          confirmPassword != null &&
          confirmPassword.isNotEmpty) {
        if (newPassword != confirmPassword) {
          debugPrint("Passwords do not match");
          return false;
        }

        await _userService.changePassword(
          oldPassword: oldPassword ?? '',
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );
      }

      if (updatedUser != null) {
        user = updatedUser;

        // final postsManager = WidgetsBinding
        //     .instance
        //     .focusManager
        //     .primaryFocus
        //     ?.context
        //     ?.read<PostsManager>();
        // postsManager?.updateUserInfoInPosts(updatedUser);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("saveProfile error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading = true;
      notifyListeners();
      await _userService.deleteUser();
    } catch (e) {
      debugPrint("deleteAccount error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePasswordIfNeeded({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty && confirmPassword.isEmpty) {
      return true;
    }

    if (newPassword != confirmPassword) {
      debugPrint("Passwords do not match");
      return false;
    }

    try {
      final userService = _userService;
      await userService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      debugPrint("changePasswordIfNeeded error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _userService.logout();
  }

  void openEditPanel() {
    if (!panelController.isPanelOpen) panelController.open();
  }
}
