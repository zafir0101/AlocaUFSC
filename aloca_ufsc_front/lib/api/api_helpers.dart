import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session.dart';


Map<String, String> authHeaders() => {
      'Content-Type': 'application/json',
      if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
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