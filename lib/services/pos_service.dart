import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';
import '../models/stock.dart';
import '../models/product.dart';
import 'auth_service.dart';

class PosService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }

  /// Lista produtos disponíveis em uma condicional
  Future<List<Stock>> getAvailableStock(int conditionalId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/condicional/$conditionalId/itens/'),
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
            id: item['id'], // ID do item da condicional
            produtoId: item['produto_id'],
            almoxarifadoId: 0, // Não relevante aqui
            quantidade: qtd > 0 ? qtd : 0,
            produtoDescricao: produto['descricao'],
            precoVenda:
                double.tryParse(produto['preco_venda']?.toString() ?? '0') ??
                0.0,
            produto: produto.isNotEmpty && produto['id'] != null
                ? Product.fromJson(produto)
                : null,
          );
        }).toList();
      }
      return [];
    }

    throw Exception('Erro ao carregar itens da condicional: ${response.body}');
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
