import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';
import '../models/product.dart';

class ProductService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<Product>> listProducts() async {
    final token = await TokenStorage.getToken();

    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse('$baseUrl/produto'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['produto'];
      return data.map((json) => Product.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    }

    throw Exception('Erro ao carregar produtos: ${response.statusCode}');
  }
}
