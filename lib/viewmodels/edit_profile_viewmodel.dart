import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/repository/user_repository.dart';
import 'package:flutter/material.dart';

class EditProfileViewModel with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final User _initialUser;

  late TextEditingController bioController;
  late TextEditingController linkController;
  late bool isPrivateProfile = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User get user => _initialUser;

  EditProfileViewModel({required User user}) : _initialUser = user {
    bioController = TextEditingController(text: user.bio);
    linkController = TextEditingController(text: '');
  }

  void setPrivateProfile(bool value) {
    isPrivateProfile = value;
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.updateUserProfile(
        _initialUser.id,
        bioController.text,
        isPrivateProfile,
      );
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
    }
  }

  @override
  void dispose() {
    bioController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
