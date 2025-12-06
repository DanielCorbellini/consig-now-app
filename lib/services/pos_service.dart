import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';
import '../models/stock.dart';
import 'auth_service.dart';

class PosService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }

  /// Lista produtos do estoque, opcionalmente filtrado por almoxarifado
  Future<List<Stock>> listStock() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    String queryString = '';
    final user = await AuthService().profile(token);

    if (user == null) {
      throw Exception('Não foi possível obter os dados do usuário');
    }

    queryString = '?usuario_id=${user.id}';

    final response = await http.get(
      Uri.parse('$_baseUrl/estoques$queryString'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['stocks'] != null) {
        final List<dynamic> stocksJson = data['stocks'];
        return stocksJson.map((json) => Stock.fromJson(json)).toList();
      }
      return [];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Falha ao carregar estoque: ${response.body}');
    }
  }

  /// Cria uma nova venda vinculada a uma condicional
  Future<int> createSale({
    required int condicionalId,
    required int? clienteId,
    String? formaPagamento,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final user = await AuthService().profile(token);
    if (user == null) {
      throw Exception('Não foi possível obter os dados do usuário');
    }

    final representanteId = user.id;

    final response = await http.post(
      Uri.parse('$_baseUrl/vendas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'representante_id': representanteId,
        'cliente_id': clienteId,
        'condicional_id': condicionalId,
        'data_venda': DateTime.now().toIso8601String(),
        'forma_pagamento': formaPagamento ?? 'pendente',
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['venda'] != null) {
        return data['venda']['id'];
      }
      throw Exception('Erro ao criar venda: resposta inválida');
    } else {
      throw Exception('Falha ao criar venda: ${response.body}');
    }
  }

  /// Adiciona um item à venda
  Future<void> addSaleItem({
    required int vendaId,
    required int produtoId,
    required int quantidade,
    required double precoUnitario,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/vendas/$vendaId/itens/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'produto_id': produtoId,
        'quantidade': quantidade,
        'preco_unitario': precoUnitario,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao adicionar item: ${response.body}');
    }
  }

  /// Finaliza uma venda
  Future<void> finalizeSale(int vendaId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/vendas/$vendaId/finalizar'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao finalizar venda: ${response.body}');
    }
  }
}
