// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EngineService {
  // ⚙️ CONFIGURATION - Set your local IP here
  static const String _localIp = "192.168.0.110";
  
  // Production backend URL
  static const String _prodUrl = "https://chess-api.onrender.com";
  
  /// 🎯 Smart URL Selection - Works for ALL environments
  static String get baseUrl {
    // 🌐 WEB
    if (kIsWeb) {
      if (kDebugMode) {
        // Local web development
        return "http://localhost:3000";
      } else {
        // Production web (Vercel)
        return _prodUrl;
      }
    }
    
    // 📱 MOBILE (iOS Simulator & Physical Device)
    if (kDebugMode) {
      // Local development - Use your computer's IP
      return "http://$_localIp:3000";
    } else {
      // Production mobile app
      return _prodUrl;
    }
  }

  /// Manual URL override for testing
  static String? _urlOverride;
  
  static void setUrlOverride(String? url) {
    _urlOverride = url;
    debugPrint("🔧 URL Override: $url");
  }
  
  static void clearUrlOverride() {
    _urlOverride = null;
    debugPrint("🔧 URL Override cleared");
  }

  static String get _effectiveUrl {
    if (_urlOverride != null) {
      debugPrint("🌐 Using override URL: $_urlOverride");
      return _urlOverride!;
    }
    
    final url = baseUrl;
    if (kDebugMode) {
      debugPrint("🌐 Using auto-detected URL: $url");
      debugPrint("📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      debugPrint("🔧 Debug Mode: $kDebugMode");
    }
    return url;
  }

  /// ===============================
  /// Analyze FULL GAME (moves array)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeGame(List<String> moves) async {
    final url = "$_effectiveUrl/analyze-game";
    
    try {
      debugPrint("🔗 [analyzeGame] Calling: $url");
      debugPrint("📊 [analyzeGame] Moves: ${moves.length}");

      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"moves": moves}),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception("Request timeout - backend not responding");
            },
          );

      debugPrint("✅ [analyzeGame] Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ [analyzeGame] Error: ${response.body}");
        throw Exception("Engine error (${response.statusCode}): ${response.body}");
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint("📥 [analyzeGame] Success");
      return result;
      
    } on SocketException catch (e) {
      debugPrint("❌ [analyzeGame] Connection failed: $e");
      debugPrint("💡 Make sure backend is running at: $_effectiveUrl");
      throw Exception("Cannot connect to backend. Is it running?");
    } catch (e) {
      debugPrint("❌ [analyzeGame] Exception: $e");
      rethrow;
    }
  }

  /// ===============================
  /// Analyze SINGLE POSITION (FEN)
  /// ===============================
  static Future<Map<String, dynamic>> analyzeFen(String fen) async {
    final url = "$_effectiveUrl/analyze-batch";
    
    try {
      debugPrint("🔗 [analyzeFen] Calling: $url");
      debugPrint("📊 [analyzeFen] FEN: ${fen.substring(0, min(30, fen.length))}...");

      final response = await http
          .post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"fen": fen}),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception("Request timeout - backend not responding");
            },
          );

      debugPrint("✅ [analyzeFen] Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ [analyzeFen] Error: ${response.body}");
        throw Exception("Engine error (${response.statusCode}): ${response.body}");
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint("📥 [analyzeFen] Success");
      return result;
      
    } on SocketException catch (e) {
      debugPrint("❌ [analyzeFen] Connection failed: $e");
      debugPrint("💡 Make sure backend is running at: $_effectiveUrl");
      throw Exception("Cannot connect to backend. Is it running?");
    } catch (e) {
      debugPrint("❌ [analyzeFen] Exception: $e");
      rethrow;
    }
  }

  /// ===============================
  /// Health check
  /// ===============================
  static Future<bool> checkHealth() async {
    try {
      final url = "$_effectiveUrl/health";
      debugPrint("🏥 Health check: $url");
      
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      
      final healthy = response.statusCode == 200;
      debugPrint(healthy ? "✅ Backend is healthy" : "❌ Backend unhealthy");
      return healthy;
    } on SocketException catch (e) {
      debugPrint("❌ Health check failed - Connection error: $e");
      return false;
    } catch (e) {
      debugPrint("❌ Health check failed: $e");
      return false;
    }
  }

  /// Helper function
  static int min(int a, int b) => a < b ? a : b;
}