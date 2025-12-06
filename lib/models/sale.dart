import 'package:consig_now_app/models/representative.dart';

class Sale {
  final int id;
  final int? condicionalId;
  final String? dataVenda;
  final double? valorTotal;
  final String? formaPagamento;
  final String? status;
  final Representative? representante;

  Sale({
    required this.id,
    this.condicionalId,
    this.dataVenda,
    this.valorTotal,
    this.formaPagamento,
    this.status,
    this.representante,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    String? repName;
    if (json['condicional'] != null &&
        json['condicional']['representante'] != null &&
        json['condicional']['representante']['user'] != null) {
      repName = json['condicional']['representante']['user']['name'];
    }

    return Sale(
      id: json['id'],
      condicionalId: json['condicional_id'],
      dataVenda: json['data_venda'],
      valorTotal: json['valor_total'] != null
          ? double.tryParse(json['valor_total'].toString())
          : 0.0,
      formaPagamento: json['forma_pagamento'],
      status: json['status'],
      representante: json['representante'] != null
          ? Representative.fromJson(json['representante'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condicional_id': condicionalId,
      'data_venda': dataVenda,
      'valor_total': valorTotal,
      'forma_pagamento': formaPagamento,
      'status': status,
    };
  }
}
