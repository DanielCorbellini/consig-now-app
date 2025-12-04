import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import 'package:consig_now_app/storage/token_storage.dart';

class SaleService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }

  Future<List<Sale>> listSales({Map<String, dynamic>? filters}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    String queryString = '';
    if (filters != null && filters.isNotEmpty) {
      final queryParams = filters.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      queryString = '?$queryParams';
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/vendas$queryString'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> salesJson = data['data'];
        return salesJson.map((json) => Sale.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Falha ao carregar vendas: ${response.body}');
    }
  }

  Future<void> updateSale(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/vendas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar venda: ${response.body}');
    }
  }

  Future<void> deleteSale(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/vendas/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao excluir venda: ${response.body}');
    }
  }

  Future<List<SaleItem>> listSaleItems(int saleId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/vendas/$saleId/itens/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> itemsJson = data['data'];
        return itemsJson.map((json) => SaleItem.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Falha ao carregar itens da venda: ${response.body}');
    }
  }
}
