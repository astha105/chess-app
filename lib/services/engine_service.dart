import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineService {
  /// 🚀 LIVE Railway backend
  static const String _base =
      "https://chess-app-production-34ba.up.railway.app";

  /// Analyze full game using backend engine
  static Future<Map<String, dynamic>> analyzeGame(
    List<String> moves,
  ) async {
    if (moves.isEmpty) {
      return {"moves": []};
    }

    final response = await http.post(
      Uri.parse("$_base/analyze-batch"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "moves": moves, // ✅ backend expects THIS
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Backend error ${response.statusCode}: ${response.body}",
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
