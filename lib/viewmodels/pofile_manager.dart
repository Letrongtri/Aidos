import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/user_service.dart';

class ProfileManager extends ChangeNotifier {
  final panelController = PanelController();
  final _userService = UserService();

  User? user;
  bool isLoading = false;

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _userService.fetchCurrentUser();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void openEditPanel() {
    panelController.open();
  }

  void closeEditPanel() {
    panelController.close();
  }
}
