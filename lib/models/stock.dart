class Stock {
  final int id;
  final int almoxarifadoId;
  final int produtoId;
  final int quantidade;
  final String? produtoDescricao;
  final double? precoVenda;
  final double? precoCusto;
  final String? categoriaDescricao;

  Stock({
    required this.id,
    required this.almoxarifadoId,
    required this.produtoId,
    required this.quantidade,
    this.produtoDescricao,
    this.precoVenda,
    this.precoCusto,
    this.categoriaDescricao,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    final produto = json['produto'];
    return Stock(
      id: json['id'],
      almoxarifadoId: json['almoxarifado_id'],
      produtoId: json['produto_id'],
      quantidade: json['quantidade'] ?? 0,
      produtoDescricao: produto?['descricao'],
      precoVenda: produto != null
          ? double.tryParse(produto['preco_venda'].toString())
          : null,
      precoCusto: produto != null
          ? double.tryParse(produto['preco_custo'].toString())
          : null,
      categoriaDescricao: produto?['categoria']?['descricao'],
    );
  }
}
