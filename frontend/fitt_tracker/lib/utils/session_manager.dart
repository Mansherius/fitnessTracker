// lib/utils/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'session_token';

  static Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
  }

  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Checks if a session token exists and is valid
  static Future<bool> isSessionValid() async {
    final token = await getSession();
    return token != null && token.isNotEmpty;
  }
}
