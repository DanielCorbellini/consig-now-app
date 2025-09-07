import 'dart:convert';
import 'package:consig_now_app/storage/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
// Ver depois

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      await TokenStorage.saveToken(user.token);
      return User.fromJson(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Credenciais inválidas');
    }

    return null;
  }

  Future<bool> logout() async {
    final token = await TokenStorage.getToken();

    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await TokenStorage.clearToken();
      return true;
    }

    return false;
  }
}
