import 'package:consig_now_app/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? token;
  final AuthService _authService = AuthService();
  final _auth = LocalAuthentication();

  User? get user => _user;
  bool get isAuthenticaded => _user != null;

  Future<bool> login(String email, String password) async {
    final userData = await _authService.login(email, password);

    if (userData != null) {
      _user = userData.user;
      await TokenStorage.saveToken(userData.token);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> loginWithBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    final savedToken = await TokenStorage.getToken();
    if (savedToken == null) return false;

    final didAuthenticate = await _auth.authenticate(
      localizedReason: 'Autentique-se para acessar o app',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (didAuthenticate) {
      final profile = await _authService.profile(savedToken);
      if (profile != null) {
        token = savedToken;
        _user = profile;
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  Future<void> enableBiometrics() async {
    final secureStorage = TokenStorage();
    await secureStorage.setBiometricsEnabled(true);
  }

  Future<bool> logout() async {
    final AuthService authService = AuthService();
    final token = await TokenStorage.getToken();

    if (token == null) return false;

    final isLoggedOut = await authService.logout(token);

    if (isLoggedOut) {
      _user = null;
      notifyListeners();
      return true;
    }

    return false;
  }
}
