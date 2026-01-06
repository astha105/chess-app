import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineService {
  // 🔥 CHANGE THIS TO YOUR RAILWAY DOMAIN
  static const String _base =
      "https://chess-app-production-34ba.up.railway.app";

  static Future<Map<String, dynamic>> analyzeGame(
      List<String> moves) async {
    final response = await http.post(
      Uri.parse("$_base/analyze-batch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "moves": moves, // ✅ MATCHES BACKEND
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Backend error: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
