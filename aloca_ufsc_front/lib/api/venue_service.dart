import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/venue_model.dart';
import '../models/api_model.dart';

const String baseUrl = 'http://10.0.2.2:8080/api/venues';

ApiRequest<List<Venue>> fetchVenues() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return Result.ok(body.map((json) => Venue.fromJson(json)).toList());
    }
    return Result.error(jsonDecode(response.body));
}

ApiRequest<Venue> createVenue(Venue venue) async {
    final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(venue.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Result.ok(Venue.fromJson(jsonDecode(response.body)));
    }
    return Result.error(jsonDecode(response.body));
}

ApiRequest<Venue> updateVenue(String id, Venue venue) async {
    final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(venue.toJson()),
    );
    if (response.statusCode == 200) {
      return Result.ok(Venue.fromJson(jsonDecode(response.body)));
    }
    return Result.error(jsonDecode(response.body));
}

ApiRequest<void> deleteVenue(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
        return Result.error(jsonDecode(response.body));
        }
    return Result.ok(());
}

