import 'dart:convert';
import 'package:http/http.dart' as http;
import '../user_interface/venue/venue_model.dart';

class VenueService {
  // Use http://10.0.2.2:8080 para Android Emulator ou http://localhost:8080 para Web/iOS
  static const String baseUrl = 'http://10.0.2.2:8080/api/venues';

  Future<List<Venue>> fetchVenues() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Venue.fromJson(json)).toList();
    }
    throw Exception('Failed to load venues');
  }

  Future<Venue> createVenue(Venue venue) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(venue.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Venue.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create venue');
  }

  Future<Venue> updateVenue(String id, Venue venue) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(venue.toJson()),
    );
    if (response.statusCode == 200) {
      return Venue.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update venue');
  }

  Future<void> deleteVenue(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete venue');
    }
  }
}