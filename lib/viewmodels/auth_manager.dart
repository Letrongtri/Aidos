import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  User? _loggedInUser;

  AuthManager() {
    _authService = AuthService(
      onAuthChange: (User? user) {
        _loggedInUser = user;
        notifyListeners();
      },
    );
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(String email, String username, String password) {
    return _authService.signup(email, username, password);
  }

  Future<User> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (_loggedInUser != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    return _authService.logout();
  }
}
