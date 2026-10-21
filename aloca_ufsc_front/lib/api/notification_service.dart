import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import 'api_helpers.dart'; 
import 'package:aloca_ufsc_front/models/auth_model.dart';
import '../models/api_model.dart';

const String baseUrl = 'http://10.0.2.2:8080/api/notifications';

ApiError _parseError(int statusCode) {
  if (statusCode == 401) return ApiError.expiredAccessToken;
  if (statusCode == 403) return ApiError.invalidSession; 
  return ApiError.badRequest;
}

ApiRequest<List<AppNotification>> fetchNotifications(AccessToken accessToken) async {
  final response = await http.get(Uri.parse(baseUrl), headers: getHeaders(accessToken));
  if (response.statusCode == 200) {
    final List<dynamic> body = decodeBody(response);
    final notifications = body.map((json) => AppNotification.fromJson(json)).toList();
    return Result.ok(notifications);
  }
  return Result.error(_parseError(response.statusCode));
}

ApiRequest<int> fetchUnreadCount(AccessToken accessToken) async {
  final response = await http.get(Uri.parse('$baseUrl/unread-count'), headers: getHeaders(accessToken));
  if (response.statusCode == 200) {
    final count = (decodeBody(response)['naoLidas'] as num).toInt();
    return Result.ok(count);
  }
  return Result.error(_parseError(response.statusCode));
}

ApiRequest<void> markAsRead(String id, AccessToken accessToken) async {
  final response = await http.patch(Uri.parse('$baseUrl/$id/read'), headers: getHeaders(accessToken));
  if (response.statusCode == 200 || response.statusCode == 204) {
    return Result.ok(null);
  }
  return Result.error(_parseError(response.statusCode));
}

ApiRequest<void> markAllAsRead(AccessToken accessToken) async {
  final response = await http.patch(Uri.parse('$baseUrl/read-all'), headers: getHeaders(accessToken));
  if (response.statusCode == 200 || response.statusCode == 204) {
    return Result.ok(null);
  }
  return Result.error(_parseError(response.statusCode));
}

ApiRequest<void> delete(String id, AccessToken accessToken) async {
  final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: getHeaders(accessToken));
  if (response.statusCode == 200 || response.statusCode == 204) {
    return Result.ok(null);
  }
  return Result.error(_parseError(response.statusCode));
}

ApiRequest<void> deleteRead(AccessToken accessToken) async {
  final response = await http.delete(Uri.parse('$baseUrl/read'), headers: getHeaders(accessToken));
  if (response.statusCode == 200 || response.statusCode == 204) {
    return Result.ok(null);
  }
  return Result.error(_parseError(response.statusCode));
}
