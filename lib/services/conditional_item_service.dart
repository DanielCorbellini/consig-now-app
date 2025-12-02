import 'dart:convert';

import 'package:consig_now_app/models/conditional_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:consig_now_app/storage/token_storage.dart';

class ConditionalItemService {
  Future<List<ConditionalItem>> listItemConditional(int id) async {
    final token = await TokenStorage.getToken();

    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/condicional/$id/itens'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['condicional'];
      return data.map((json) => ConditionalItem.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    }

    throw Exception('Erro ao carregar as condicionais: ${response.statusCode}');
  }

  Future<void> deleteItem(int conditionalId, int itemId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.delete(
      Uri.parse(
        '${dotenv.env['BASE_URL']}/condicional/$conditionalId/itens/$itemId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar item: ${response.body}');
    }
  }

  Future<void> updateItem(
    int conditionalId,
    int itemId,
    Map<String, dynamic> data,
  ) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.put(
      Uri.parse(
        '${dotenv.env['BASE_URL']}/condicional/$conditionalId/itens/$itemId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar item: ${response.body}');
    }
  }

  Future<void> addItem(int conditionalId, Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/condicional/$conditionalId/itens/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao adicionar item: ${response.body}');
    }
  }
}
