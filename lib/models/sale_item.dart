class SaleItem {
  final int id;
  final int vendaId;
  final int produtoId;
  final String produtoDescricao;
  final int quantidade;
  final double precoUnitario;

  SaleItem({
    required this.id,
    required this.vendaId,
    required this.produtoId,
    required this.produtoDescricao,
    required this.quantidade,
    required this.precoUnitario,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    String prodDesc = 'Produto #${json['produto_id']}';
    if (json['produto'] != null) {
      prodDesc = json['produto']['descricao'] ?? prodDesc;
    }

    return SaleItem(
      id: json['id'],
      vendaId: json['venda_id'],
      produtoId: json['produto_id'],
      produtoDescricao: prodDesc,
      quantidade: json['quantidade'],
      precoUnitario: json['preco_unitario'] != null
          ? double.tryParse(json['preco_unitario'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venda_id': vendaId,
      'produto_id': produtoId,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
    };
  }
}
