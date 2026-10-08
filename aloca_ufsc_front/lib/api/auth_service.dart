import 'dart:convert';
import 'package:aloca_ufsc_front/models/auth_model.dart';
import '../models/api_model.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8080/api/auth';

ApiRequest<AuthInfo> requestAuthInfo(RefreshToken token) async {
    final request = {'refreshToken': token};
    final response = await http.post(
        Uri.parse('$baseUrl/login/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
    ); 

    if (response.statusCode != 200 || response.statusCode != 201) return Result.error(jsonDecode(response.body));

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}

ApiRequest<AuthInfo> login(LoginRequest request) async {
    final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 || response.statusCode != 201) return Result.error(jsonDecode(response.body));

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}

ApiRequest<AuthInfo> signUp(SignUpRequest request) async {
    final response = await http.post(
        Uri.parse('$baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 || response.statusCode != 201) return Result.error(jsonDecode(response.body));

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}
