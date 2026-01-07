import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class Environment {
  static String get backendUrl {
    if (kDebugMode) {
      // Local development
      return 'http://localhost:3000';
    }
    // Production (Vercel)
    return 'https://your-app.up.railway.app';
  }
  
  static String get analyzeBatchUrl => '$backendUrl/analyze-batch';
  static String get healthCheckUrl => '$backendUrl/health';
}