import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final _userService = UserService();
  final panelController = PanelController();

  bool isLoading = false;
  String? errorMessage;
  User? user;

  Future<void> loadCurrentUser() async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _userService.fetchCurrentUser();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void openEditPanel() {
    if (panelController.isPanelClosed) {
      panelController.open();
    }
  }

  void closeEditPanel() {
    if (panelController.isPanelOpen) {
      panelController.close();
    }
  }
}
