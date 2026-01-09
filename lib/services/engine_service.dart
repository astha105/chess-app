// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EngineService {
  // ⚙️ Local machine IP (for mobile debug only)
  static const String _localIp = "192.168.0.110";

  // ⭐ Railway production backend
  static const String _prodUrl =
      "https://chess-app-backend-production-5d7e.up.railway.app";

  /// 🌍 FINAL URL RESOLUTION (SAFE & CORRECT)
  static String get baseUrl {
    // 🌐 WEB → ALWAYS PRODUCTION
    if (kIsWeb) {
      return _prodUrl;
    }

    // 📱 MOBILE
    if (kDebugMode) {
      return "http://$_localIp:3000";
    }

    return _prodUrl;
  }

  static String get _effectiveUrl {
    debugPrint("🌐 Backend URL: $baseUrl");
    return baseUrl;
  }

  /// ===============================
  /// Analyze FULL GAME
  /// ===============================
  static Future<Map<String, dynamic>> analyzeGame(List<String> moves) async {
    final url = "$_effectiveUrl/analyze-game";

    final response = await http
        .post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"moves": moves}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception("Engine error: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// ===============================
  /// Analyze SINGLE POSITION
  /// ===============================
  static Future<Map<String, dynamic>> analyzeFen(String fen) async {
    final url = "$_effectiveUrl/analyze-batch";

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

  /// ===============================
  /// Health Check
  /// ===============================
  static Future<bool> checkHealth() async {
    try {
      final response =
          await http.get(Uri.parse("$_effectiveUrl/health"));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
