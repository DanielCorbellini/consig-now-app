import 'package:consig_now_app/models/user.dart';

class Representative {
  final int id;
  final int userId;
  final String? telefone;
  final User? user;

  Representative({
    required this.id,
    required this.userId,
    required this.telefone,
    this.user,
  });

  factory Representative.fromJson(Map<String, dynamic> json) {
    return Representative(
      id: json['id'],
      userId: json['user_id'],
      telefone: json['telefone'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
