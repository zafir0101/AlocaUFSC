import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aloca_ufsc_front/models/auth_model.dart';

Map<String, String> getHeaders(AccessToken accessToken) => {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
};

dynamic decodeBody(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

Exception apiError(http.Response response, String fallback) {
  try {
    final body = decodeBody(response);
    if (body is Map && body['mensagem'] != null) {
      return Exception(body['mensagem']);
    }
  } catch (_) {}
  return Exception(fallback);
}
