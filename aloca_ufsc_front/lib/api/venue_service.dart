import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/venue_model.dart';
import '../models/auth_model.dart';
import '../models/api_model.dart';

const String baseUrl = 'http://10.0.2.2:8080/api/venues';

Map<String, String> _getHeaders(AccessToken token) => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
};

dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

String _extractMessage(http.Response response) {
  try {
    final body = _decode(response);
    return body['mensagem'] ?? 'Erro no processamento do espaço.';
  } catch (_) {
    return 'Erro inesperado no serviço de espaços.';
  }
}

ApiError? _checkSessionError(int statusCode) {
  if (statusCode == 401) return ApiError.expiredAccessToken;
  if (statusCode == 403) return ApiError.invalidSession;
  return null;
}

ApiRequest<List<Venue>> fetchVenues(AccessToken accessToken) async {
  final response = await http.get(Uri.parse(baseUrl), headers: _getHeaders(accessToken));
  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map((json) => Venue.fromJson(json)).toList());
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}

ApiRequest<List<Venue>> fetchVenuesWithFilter(AccessToken accessToken) async {
  final response = await http.get(Uri.parse("$baseUrl/filter"), headers: _getHeaders(accessToken));
  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map((json) => Venue.fromJson(json)).toList());
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}

ApiRequest<List<CampusCenter>> fetchCampus(AccessToken accessToken) async {
  final response = await http.get(Uri.parse('$baseUrl/campus'), headers: _getHeaders(accessToken));
  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map((json) => CampusCenter.fromJson(json)).toList());
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}

ApiRequest<Venue> createVenue(Venue venue, AccessToken accessToken) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: _getHeaders(accessToken),
    body: jsonEncode(venue.toRequestJson()),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    return Result.ok(Venue.fromJson(_decode(response)));
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}

ApiRequest<Venue> updateVenue(String id, Venue venue, AccessToken accessToken) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id'),
    headers: _getHeaders(accessToken),
    body: jsonEncode(venue.toRequestJson()),
  );
  if (response.statusCode == 200) {
    return Result.ok(Venue.fromJson(_decode(response)));
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}

ApiRequest<void> deleteVenue(String id, AccessToken accessToken) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/$id'),
    headers: _getHeaders(accessToken)
  );
  if (response.statusCode == 200 || response.statusCode == 204) {
    return Result.ok(null);
  }
  
  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);
  
  throw Exception(_extractMessage(response));
}
