import 'dart:convert';
import 'package:http/http.dart' as http;

class EngineService {
  static const _base = "http://localhost:3000";

  static Future<Map<String, dynamic>> analyzeGame(
      List<String> moves) async {
    final positions = <Map<String, dynamic>>[];

    String fen = "startpos";

    for (final move in moves) {
      positions.add({
        "fen": fen,
        "move": move,
      });

      fen = "position $fen moves $move";
    }

    final res = await http.post(
      Uri.parse("$_base/analyze-batch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"positions": positions}),
    );

    if (res.statusCode != 200) {
      throw Exception("Backend error");
    }

    return jsonDecode(res.body);
  }
}
