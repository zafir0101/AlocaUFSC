import 'dart:convert';

import 'package:http/http.dart' as http;

import '../user_interface/allocation/manage_venue/venue_model.dart';
import 'api_helpers.dart';

class VenueService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/venues';

  Future<List<Venue>> fetchVenues() async {
    final response = await http.get(Uri.parse(baseUrl), headers: authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> body = decodeBody(response);
      return body.map((json) => Venue.fromJson(json)).toList();
    }
    throw apiError(response, 'Falha ao carregar os espaços.');
  }

  // Centros da UFSC e prédios sugeridos.
  Future<List<CampusCenter>> fetchCampus() async {
    final response = await http.get(Uri.parse('$baseUrl/campus'), headers: authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> body = decodeBody(response);
      return body.map((json) => CampusCenter.fromJson(json)).toList();
    }
    throw apiError(response, 'Falha ao carregar os centros da UFSC.');
  }

  Future<Venue> createVenue(Venue venue) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: authHeaders(),
      body: jsonEncode(venue.toRequestJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Venue.fromJson(decodeBody(response));
    }
    throw apiError(response, 'Falha ao cadastrar o espaço.');
  }

  Future<Venue> updateVenue(String id, Venue venue) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: authHeaders(),
      body: jsonEncode(venue.toRequestJson()),
    );
    if (response.statusCode == 200) {
      return Venue.fromJson(decodeBody(response));
    }
    throw apiError(response, 'Falha ao salvar o espaço.');
  }

  Future<void> deleteVenue(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: authHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw apiError(response, 'Falha ao excluir o espaço.');
    }
  }
}