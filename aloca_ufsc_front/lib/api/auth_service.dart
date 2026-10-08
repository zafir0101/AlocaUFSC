import 'dart:convert';
import 'package:aloca_ufsc_front/models/auth_model.dart';
import '../models/api_model.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8080/api/auth';
    
// TODO: Tratamento de erro entre back e front 

ApiRequest<AuthInfo> requestAuthInfo(RefreshToken token) async {
    final request = {'refreshToken': token};
    final response = await http.post(
        Uri.parse('$baseUrl/login/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
    ); 

    if (response.statusCode != 200 && response.statusCode != 201) return Result.error(ApiError.badRequest);

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}

ApiRequest<AuthInfo> login(LoginRequest request) async {
    final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) return Result.error(ApiError.invalidEmailOrPassword);

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}

ApiRequest<AuthInfo> register(SignUpRequest request) async {
    final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) return Result.error(ApiError.signUpError);

    return Result.ok(AuthInfo.fromJson(jsonDecode(response.body)));
}
