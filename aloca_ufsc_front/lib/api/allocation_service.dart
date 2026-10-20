import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/api_model.dart';
import '../models/auth_model.dart';
import '../models/allocation_model.dart';

const String baseUrl = 'http://10.0.2.2:8080/api/allocations';

Map<String, String> _getHeaders(AccessToken token) => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
};

dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

String _extractMessage(http.Response response) {
  try {
    final body = _decode(response);
    return body['mensagem'] ?? 'Erro no processamento da alocação.';
  } catch (_) {
    return 'Erro inesperado no serviço de alocação.';
  }
}

ApiError? _checkSessionError(int statusCode) {
  if (statusCode == 401) return ApiError.expiredAccessToken;
  if (statusCode == 403) return ApiError.invalidSession;
  return null;
}

ApiRequest<List<EventOption>> fetchEligibleEvents(AccessToken accessToken) async {
  final response = await http.get(
    Uri.parse('$baseUrl/eligible-events'),
    headers: _getHeaders(accessToken),
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map<EventOption>((json) => EventOption.fromJson(json)).toList());
  }

  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);

  throw Exception(_extractMessage(response));
}

ApiRequest<Allocation> createAllocation(
  int eventId,
  String venueId,
  DateTime start,
  DateTime end,
  AccessToken accessToken,
) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: _getHeaders(accessToken),
    body: jsonEncode({
      'eventId': eventId,
      'venueId': venueId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return Result.ok(Allocation.fromJson(_decode(response)));
  }

  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);

  throw Exception(_extractMessage(response));
}

ApiRequest<List<Allocation>> fetchAllocationsByStatus(
  String status,
  AccessToken accessToken,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl?status=$status'),
    headers: _getHeaders(accessToken),
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map<Allocation>((json) => Allocation.fromJson(json)).toList());
  }

  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);

  throw Exception(_extractMessage(response));
}

ApiRequest<Allocation> approveAllocation(int id, AccessToken accessToken) async {
  final response = await http.post(
    Uri.parse('$baseUrl/$id/approve'),
    headers: _getHeaders(accessToken),
  );

  if (response.statusCode == 200) {
    return Result.ok(Allocation.fromJson(_decode(response)));
  }

  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);

  throw Exception(_extractMessage(response));
}

ApiRequest<Allocation> rejectAllocation(
  int id,
  String? reason,
  AccessToken accessToken,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/$id/reject'),
    headers: _getHeaders(accessToken),
    body: jsonEncode({'reason': reason}),
  );

  if (response.statusCode == 200) {
    return Result.ok(Allocation.fromJson(_decode(response)));
  }

  final sessionError = _checkSessionError(response.statusCode);
  if (sessionError != null) return Result.error(sessionError);

  throw Exception(_extractMessage(response));
}
