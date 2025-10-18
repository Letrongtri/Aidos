import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/repository/user_repository.dart';
import 'package:flutter/material.dart';

class EditProfileViewModel with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final User _initialUser;

  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // Luôn private
  final bool isPrivateProfile = true;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User get user => _initialUser;

  EditProfileViewModel({required User user}) : _initialUser = user {
    usernameController = TextEditingController(text: user.username);
    bioController = TextEditingController(text: user.bio ?? '');
    emailController = TextEditingController(text: user.email ?? '');
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  /// Validate before save; trả về message null nếu hợp lệ
  String? validateBeforeSave() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (username.isEmpty) return 'Username không được để trống.';
    if (email.isEmpty) return 'Email không được để trống.';
    // đơn giản check email basic
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email))
      return 'Email không hợp lệ.';
    if (newPass.isNotEmpty && newPass.length < 6)
      return 'Mật khẩu mới phải có ít nhất 6 ký tự.';
    if (newPass.isNotEmpty && newPass != confirm)
      return 'Mật khẩu và xác nhận mật khẩu không khớp.';
    return null;
  }

  /// Lưu profile (gọi repository).
  /// Lưu ý: Điều chỉnh `_userRepository.updateUserProfile` cho phù hợp API backend của bạn.
  Future<bool> saveProfile() async {
    final validationError = validateBeforeSave();
    if (validationError != null) {
      // có thể xử lý hiển thị lỗi ở UI bằng cách ném hoặc trả về false
      print('Validation error: $validationError');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUsername = usernameController.text.trim();
      final updatedBio = bioController.text.trim();
      final updatedEmail = emailController.text.trim();
      final newPassword = newPasswordController.text.isNotEmpty
          ? newPasswordController.text
          : null;

      // TODO: Điều chỉnh method gọi repo nếu API của bạn khác.
      // Giả sử UserRepository có method:
      // Future<void> updateUserProfile(String id, {String? username, String? bio, String? email, String? password, bool? isPrivate})
      //     await _userRepository.updateUserProfile(
      //       _initialUser.id,
      //       username: updatedUsername,
      //       bio: updatedBio,
      //       email: updatedEmail,
      //       password: newPassword,
      //       isPrivate: true,
      //     );

      return true;
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.deleteUser(_initialUser.id);
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
