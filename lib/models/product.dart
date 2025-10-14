class Product {
  final int id;
  final String descricao;
  final double preco_custo;
  final double preco_venda;
  final int categoria_id;
  final String categoria_descricao;

  Product({
    required this.id,
    required this.descricao,
    required this.preco_custo,
    required this.preco_venda,
    required this.categoria_id,
    required this.categoria_descricao,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      descricao: json['descricao'],
      preco_custo: double.tryParse(json['preco_custo'].toString()) ?? 0.0,
      preco_venda: double.tryParse(json['preco_venda'].toString()) ?? 0.0,
      categoria_id: json['categoria']['id'],
      categoria_descricao: json['categoria']['descricao'],
    );
  }
}
