import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isAuthenticaded => _user != null;

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email, password);

    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> logout() async {
    final AuthService authService = AuthService();

    final isLoggedOut = await authService.logout();

    if (isLoggedOut) {
      _user = null;
      notifyListeners();
      return true;
    }

    return false;
  }
}
