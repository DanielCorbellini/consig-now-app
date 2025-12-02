class Category {
  final int id;
  final String descricao;

  Category({required this.id, required this.descricao});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], descricao: json['descricao']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descricao': descricao};
  }
}
