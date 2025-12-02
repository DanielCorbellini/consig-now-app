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

  Future<void> createProduct(Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/produto'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar produto: ${response.body}');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/produto/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar produto: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/produto/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar produto: ${response.body}');
    }
  }
}
