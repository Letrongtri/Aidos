import 'dart:async';

import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  StreamSubscription? _authSubscription;

  User? _loggedInUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _loggedInUser;
  bool get isLoading => _isLoading;
  bool get isAuth => _loggedInUser != null;
  bool get isInitialized => _isInitialized;

  AuthManager() {
    _authService = AuthService(
      onAuthChange: (User? user) {
        _loggedInUser = user;
        notifyListeners();
      },
    );

    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getUserFromStore();
      if (user != null) {
        _loggedInUser = user;
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signup(String email, String username, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.signup(email, username, password);
      _loggedInUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Signup error: $e');
      _setLoading(false);
      return false;
    }
    // return _authService.signup(email, username, password);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.login(email, password);
      _loggedInUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _setLoading(false);
      return false;
    }
    // return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    final user = await _authService.getUserFromStore();
    if (_loggedInUser != null) {
      _loggedInUser = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _loggedInUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
