class User {
  final String email;

  User({required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'], // pega o email do JSON
    );
  }
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['access_token'],
    );
  }
}
