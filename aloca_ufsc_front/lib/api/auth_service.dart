import 'dart:convert';
import 'package:aloca_ufsc_front/user_interface/auth/auth_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    final erro = jsonDecode(response.body);
    throw Exception(erro['mensagem'] ?? 'Falha ao realizar login.');
  }

  Future<AuthResponse> signUp(SignUpRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    final erro = jsonDecode(response.body);
    throw Exception(erro['mensagem'] ?? 'Falha ao cadastrar usuário.');
  }
}
