// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EngineService {
  /// 🔥 SINGLE SOURCE OF TRUTH
  static const String _prodUrl =
      "https://chess-api.onrender.com"; // CHANGE if needed

  static const String _localUrl =
      "http://localhost:3000";

  /// ✅ Smart URL selection
  static String get baseUrl {
    if (kIsWeb) {
      // Web MUST use HTTPS
      return _prodUrl;
    }
    return _prodUrl; // mobile also HTTPS
  }

  /// ===============================
  /// Analyze FULL GAME (moves array)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeGame(
      List<String> moves) async {
    final url = "$baseUrl/analyze-game";
    debugPrint("🔗 Calling $url");

    final response = await http
        .post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"moves": moves}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception("Engine error: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// ===============================
  /// Analyze SINGLE POSITION (FEN)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeFen(String fen) async {
    final url = "$baseUrl/analyze-batch";
    debugPrint("🔗 Calling $url");

    final response = await http
        .post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"fen": fen}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception("Engine error: ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
