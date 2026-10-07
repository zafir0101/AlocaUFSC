import 'dart:convert';

import 'package:http/http.dart' as http;

import '../user_interface/event/event_model.dart';
import 'session.dart';

class DuplicateEventException implements Exception {
  final String message;
  final int existingEventId;

  DuplicateEventException(this.message, this.existingEventId);

  @override
  String toString() => message;
}

class EventService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/events';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };

  Future<List<Event>> fetchMyEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> body = _decode(response);
      return body.map((json) => Event.fromJson(json)).toList();
    }
    throw _error(response, 'Falha ao carregar eventos.');
  }

  Future<Event> fetchEvent(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: _headers);
    if (response.statusCode == 200) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao carregar evento.');
  }

  Future<Event> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: jsonEncode(event.toRequestJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao criar evento.');
  }

  Future<Event> updateEvent(int id, Event event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(event.toRequestJson()),
    );
    if (response.statusCode == 200) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao editar evento.');
  }

  Future<Event> cancelEvent(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/cancel'), headers: _headers);
    if (response.statusCode == 200) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao cancelar evento.');
  }

  Future<Event> suspendEvent(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/suspend'), headers: _headers);
    if (response.statusCode == 200) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao suspender evento.');
  }

  Future<Event> reactivateEvent(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/reactivate'), headers: _headers);
    if (response.statusCode == 200) {
      return Event.fromJson(_decode(response));
    }
    throw _error(response, 'Falha ao reativar evento.');
  }

  dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

  Exception _error(http.Response response, String fallback) {
    try {
      final body = _decode(response);
      if (response.statusCode == 409 && body is Map && body['eventoId'] != null) {
        return DuplicateEventException(body['mensagem'], body['eventoId']);
      }
      if (body is Map && body['mensagem'] != null) {
        return Exception(body['mensagem']);
      }
    } catch (_) {}
    return Exception(fallback);
  }
}