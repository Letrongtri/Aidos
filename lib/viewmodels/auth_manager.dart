import 'package:ct312h_project/models/user.dart';
import 'package:flutter/foundation.dart';

class AuthManager with ChangeNotifier {
  User? _loggedInUser;

  AuthManager() {
    // _
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  // Future<User> signup(String email, String password) {
  //   // return
  // }

  // Future<User> login(String email, String password) {
  //   //
  // }

  Future<void> tryAutoLogin() async {
    // final user = await _authService.getUserFromStore();
    if (_loggedInUser != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // return _authService.logout();
  }
}
