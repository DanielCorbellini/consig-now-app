class ConditionalItem {
  final int id;
  final int condicionalId;
  final int produtoId;
  final String produtoDescricao;
  final int quantidadeEntregue;
  final int quantidadeDevolvida;
  final int quantidadeVendida;

  ConditionalItem({
    required this.id,
    required this.condicionalId,
    required this.produtoId,
    required this.produtoDescricao,
    required this.quantidadeEntregue,
    required this.quantidadeDevolvida,
    required this.quantidadeVendida,
  });

  factory ConditionalItem.fromJson(Map<String, dynamic> json) {
    return ConditionalItem(
      id: json['id'],
      condicionalId: json['condicional_id'],
      produtoId: json['produto_id'],
      produtoDescricao: json['produto']['descricao'],
      quantidadeEntregue: json['quantidade_entregue'],
      quantidadeDevolvida: json['quantidade_devolvida'],
      quantidadeVendida: json['quantidade_vendida'],
    );
  }
}
