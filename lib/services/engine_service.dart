// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EngineService {
  /// 🔥 CONFIGURATION
  /// 
  /// FOR LOCAL DEVELOPMENT ON iOS SIMULATOR:
  /// Replace "YOUR_LOCAL_IP" with your computer's local IP address
  /// Find it by running: ipconfig getifaddr en0 (Mac) or ipconfig (Windows)
  /// Example: "192.168.1.100"
  static const String _localIp = "192.168.0.110"; 
  
  static const String _prodUrl = "https://chess-api.onrender.com";
  static const String _localUrl = "http://$_localIp:3000";
  static const String _webLocalUrl = "http://localhost:3000";

  /// ✅ Smart URL selection based on environment
  static String get baseUrl {
    if (kIsWeb) {
      // Web: Check if running locally (development)
      if (kDebugMode) {
        return _webLocalUrl; // localhost works fine for web
      }
      return _prodUrl; // Production web
    }
    
    // Mobile (iOS/Android)
    if (kDebugMode) {
      // Development: Use local IP
      return _localUrl;
    }
    
    // Production mobile
    return _prodUrl;
  }

  /// Alternative: Manual override for testing
  static String? _urlOverride;
  static void setUrlOverride(String? url) {
    _urlOverride = url;
  }

  static String get _effectiveUrl => _urlOverride ?? baseUrl;

  /// ===============================
  /// Analyze FULL GAME (moves array)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeGame(
      List<String> moves) async {
    final url = "$_effectiveUrl/analyze-game";
    debugPrint("🔗 Calling $url");

    try {
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
    } catch (e) {
      debugPrint("❌ Error calling $url: $e");
      rethrow;
    }
  }

  /// ===============================
  /// Analyze SINGLE POSITION (FEN)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeFen(String fen) async {
    final url = "$_effectiveUrl/analyze-batch";
    debugPrint("🔗 Calling $url");

    try {
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
    } catch (e) {
      debugPrint("❌ Error calling $url: $e");
      rethrow;
    }
  }

  /// ===============================
  /// Health check to verify connection
  /// ===============================
  static Future<bool> checkHealth() async {
    try {
      final url = "$_effectiveUrl/health";
      debugPrint("🏥 Health check: $url");
      
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Health check failed: $e");
      return false;
    }
  }
}