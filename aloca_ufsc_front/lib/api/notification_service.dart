import 'package:http/http.dart' as http;

import '../user_interface/notification/notification_model.dart';
import 'api_helpers.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/notifications';

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await http.get(Uri.parse(baseUrl), headers: authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> body = decodeBody(response);
      return body.map((json) => AppNotification.fromJson(json)).toList();
    }
    throw apiError(response, 'Falha ao carregar as notificações.');
  }

  Future<int> fetchUnreadCount() async {
    final response = await http.get(Uri.parse('$baseUrl/unread-count'), headers: authHeaders());
    if (response.statusCode == 200) {
      return (decodeBody(response)['naoLidas'] as num).toInt();
    }
    throw apiError(response, 'Falha ao carregar as notificações.');
  }

  Future<void> markAsRead(int id) async {
    final response = await http.patch(Uri.parse('$baseUrl/$id/read'), headers: authHeaders());
    if (response.statusCode != 200) {
      throw apiError(response, 'Falha ao marcar a notificação como lida.');
    }
  }

  Future<void> markAllAsRead() async {
    final response = await http.patch(Uri.parse('$baseUrl/read-all'), headers: authHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw apiError(response, 'Falha ao marcar as notificações como lidas.');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: authHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw apiError(response, 'Falha ao excluir a notificação.');
    }
  }

  // Apaga as notificações já lidas.
  Future<void> deleteRead() async {
    final response = await http.delete(Uri.parse('$baseUrl/read'), headers: authHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw apiError(response, 'Falha ao limpar as notificações.');
    }
  }
}