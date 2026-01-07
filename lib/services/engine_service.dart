import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineService {
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static Future<Map<String, dynamic>> analyzeGame(List<String> moves) async {
    print("🔗 Calling $_baseUrl/analyze-batch");

    final response = await http.post(
        Uri.parse("$_baseUrl/analyze-batch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"moves": moves}),
    )
    .timeout(const Duration(seconds: 15));
  

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }
}
