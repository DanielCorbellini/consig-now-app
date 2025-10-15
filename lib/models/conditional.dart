class Conditional {
  final int id;
  final int representante_id;
  final String? data_entrega;
  final String data_prevista_retorno;
  final String status;
  final int user_id;
  final String user_name;

  Conditional({
    required this.id,
    required this.representante_id,
    required this.data_entrega,
    required this.data_prevista_retorno,
    required this.status,
    required this.user_id,
    required this.user_name,
  });

  factory Conditional.fromJson(Map<String, dynamic> json) {
    return Conditional(
      id: json['id'],
      representante_id: json['representante_id'],
      data_entrega: json['data_entrega'],
      data_prevista_retorno: json['data_prevista_retorno'],
      status: json['status'],
      user_id: json['user_id'],
      user_name: json['user_name'],
    );
  }
}
