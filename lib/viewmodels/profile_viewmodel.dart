import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileViewModel with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final PanelController panelController = PanelController();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    _user = await _userRepository.fetchCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  void openEditPanel() {
    panelController.open();
  }
}
