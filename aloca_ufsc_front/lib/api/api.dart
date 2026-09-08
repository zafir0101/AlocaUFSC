import 'package:http/http.dart' as http;

class Api {
  static final http.Client _client = http.Client();
  static Future<String?> calc(int? num1, int? num2, String op) async {
    if (num1 == null || num2 == null) return null;

    final url = Uri.parse(
      "http://10.0.2.2:8080/calculadora/$op?num1=$num1&num2=$num2",
    );
    final response = await _client.get(url);

    return response.body;
  }
}
