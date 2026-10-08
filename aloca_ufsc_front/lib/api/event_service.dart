import 'dart:convert';

import 'package:aloca_ufsc_front/models/auth_model.dart';
import 'package:http/http.dart' as http;

import '../models/event_model.dart';
import '../models/api_model.dart';

// class DuplicateEventException implements Exception {
//     final String message;
//     final String existingEventId;
//
//     DuplicateEventException(this.message, this.existingEventId);
//
//     @override
//     String toString() => message;
// }

const String baseUrl = 'http://10.0.2.2:8080/api/events';

Map<String, String> _getHeaders(AccessToken token) => { 
  'Content-Type': 'application/json', 
  'Authorization': 'Bearer $token',
};

ApiRequest<List<Event>> fetchMyEvents(AccessToken accessToken) async {
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: _getHeaders(accessToken));
    if (response.statusCode == 200) {
          final List<dynamic> body = _decode(response);
          return Result.ok(body.map((json) => Event.fromJson(json)).toList());
        }

    return Result.error(jsonDecode(response.body));
}

ApiRequest<Event> fetchEvent(String id, AccessToken accessToken) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: _getHeaders(accessToken));
    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }

    return Result.error(jsonDecode(response.body));
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

    return Result.error(jsonDecode(response.body));
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
    return Result.error(jsonDecode(response.body));
}

ApiRequest<Event> cancelEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/cancel'), headers: _getHeaders(accessToken));
    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }
    return Result.error(jsonDecode(response.body));
}

ApiRequest<Event> suspendEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/suspend'), headers: _getHeaders(accessToken));
    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }
    return Result.error(jsonDecode(response.body));
}

ApiRequest<Event> reactivateEvent(String id, AccessToken accessToken) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/reactivate'), headers: _getHeaders(accessToken));
    if (response.statusCode == 200) {
      return Result.ok(Event.fromJson(_decode(response)));
    }
    return Result.error(jsonDecode(response.body));
}

dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

// Exception _error(http.Response response, String fallback) {
//     try {
//         final body = _decode(response);
//         if (response.statusCode == 409 && body is Map && body['eventoId'] != null) {
//         return DuplicateEventException(body['mensagem'], body['eventoId']);
//       }
//         if (body is Map && body['mensagem'] != null) {
//         return Exception(body['mensagem']);
//       }
//     } catch (_) {}
//     return Exception(fallback);
