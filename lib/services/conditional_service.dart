import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:consig_now_app/models/conditional.dart';
import 'package:consig_now_app/models/stock.dart';
import 'package:consig_now_app/storage/token_storage.dart';

class ConditionalService {
  Future<List<Conditional>> listConditionals({
    Map<String, dynamic>? filters,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    // Ensure query parameters are Map<String, String>
    final Map<String, String> queryParams =
        filters?.map((key, value) => MapEntry(key, value?.toString() ?? '')) ??
        {};

    final uri = Uri.parse(
      '${dotenv.env['BASE_URL']}/condicional',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['condicional'];
      return data.map((json) => Conditional.fromJson(json)).toList();
    }

    if (response.statusCode == 422) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['message'];
      throw Exception(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    }

    if (response.statusCode == 404) {
      String message;
      try {
        final decodedBody = jsonDecode(response.body);
        message = (decodedBody is Map && decodedBody['message'] != null)
            ? decodedBody['message'].toString()
            : response.body;
      } catch (_) {
        message = response.body;
      }
      throw Exception(message);
    }

    throw Exception('Erro ao carregar as condicionais: ${response.statusCode}');
  }

  Future<void> deleteConditional(int id) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/condicional/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar condicional: ${response.body}');
    }
  }

  Future<void> updateConditional(int id, Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/condicional/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar condicional: ${response.body}');
    }
  }

  Future<List<Stock>> getConditionalItems(int conditionalId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/condicional/$conditionalId/itens/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['condicional'] != null) {
        final List<dynamic> items = decoded['condicional'];
        return items.map((item) {
          final produto = item['produto'] ?? {};
          final qtd =
              (item['quantidade_entregue'] ?? 0) -
              (item['quantidade_vendida'] ?? 0) -
              (item['quantidade_devolvida'] ?? 0);

          return Stock(
            id: item['id'], // ID do item da condicional, não do estoque
            produtoId: item['produto_id'],
            almoxarifadoId: 0, // Não relevante aqui
            quantidade: qtd > 0 ? qtd : 0,
            produtoDescricao: produto['nome'],
            precoVenda:
                double.tryParse(produto['preco_venda']?.toString() ?? '0') ??
                0.0,
          );
        }).toList();
      }
      return [];
    }

    throw Exception('Erro ao carregar itens da condicional: ${response.body}');
  }
}
