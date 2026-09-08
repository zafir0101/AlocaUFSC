class LoginRequest {
  final String email;
  final String senha;

  LoginRequest({required this.email, required this.senha});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
    };
  }
}

class SignUpRequest {
  final String nomeCompleto;
  final String email;
  final String senha;
  final String entity;
  final String identificador;

  SignUpRequest({
    required this.nomeCompleto,
    required this.email,
    required this.senha,
    required this.entity,
    required this.identificador,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'senha': senha,
      'entity': entity,
      'identificador': identificador,
    };
  }
}

class AuthResponse {
  final String? token;
  final String? refreshToken;
  final String? entity;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.entity,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      entity: json['tipoPerfil'],
    );
  }
}
