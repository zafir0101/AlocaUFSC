import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:aloca_ufsc_front/models/event_model.dart';
import 'package:aloca_ufsc_front/models/auth_model.dart';
import 'package:aloca_ufsc_front/models/api_model.dart';

class DuplicateEventError {
  final String message;
  final String existingEventId;

  DuplicateEventError(this.message, this.existingEventId);

  @override
  String toString() => message;
}

const String baseUrl = 'http://10.0.2.2:8080/api/events';

Map<String, String> _getHeaders(AccessToken token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', 
};

dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

ApiError _parseError(int statusCode) {
  if (statusCode == 401) return ApiError.expiredAccessToken;
  if (statusCode == 403) return ApiError.invalidSession;
  return ApiError.badRequest;
}

ApiRequest<List<Event>> fetchMyEvents(AccessToken accessToken) async {
    final response = await http.get(
        Uri.parse('$baseUrl/me'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = _decode(response);
      return Result.ok(body.map((json) => Event.fromJson(json)).toList());
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> fetchEvent(String id, AccessToken accessToken) async {
    final response = await http.get(
        Uri.parse('$baseUrl/$id'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<List<Event>> fetchEventByStatus(String status, AccessToken accessToken) async {
    final response = await http.get(
        Uri.parse('$baseUrl/status/$status'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = _decode(response);
      return Result.ok(body.map((json) => Event.fromJson(json)).toList());
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> createEvent(Event event, AccessToken accessToken) async {
    final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(accessToken),
        body: jsonEncode(event.toRequestJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> updateEvent(String id, Event event, AccessToken accessToken) async {
    final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(accessToken),
        body: jsonEncode(event.toRequestJson()),
    );

    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> cancelEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/$id/cancel'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> suspendEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/$id/suspend'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<Event> reactivateEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(
        Uri.parse('$baseUrl/$id/reactivate'), 
        headers: _getHeaders(accessToken)
    );

    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(_parseError(response.statusCode));
}

ApiRequest<List<Event>> fetchEligibleEvents(AccessToken accessToken) async {
  final response = await http.get(
    Uri.parse('$baseUrl/eligible-events'),
    headers: _getHeaders(accessToken),
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = _decode(response);
    return Result.ok(body.map<Event>((json) => Event.fromJson(json)).toList());
  }

  final sessionError = _parseError(response.statusCode);
  return Result.error(sessionError);
}
