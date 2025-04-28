// lib/utils/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyAuthToken = 'authToken';
  static const _keySessionTimestamp = 'sessionTimestamp';

  /// Save session details (token + timestamp).
  static Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    await prefs.setInt(
      _keySessionTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Retrieve the authentication token (if any).
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// Check if session is still valid.
  /// Defaults to a 7-day expiry.
  static Future<bool> isSessionValid({
    Duration validDuration = const Duration(days: 7),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAuthToken);
    final ts = prefs.getInt(_keySessionTimestamp);
    if (token == null || ts == null) return false;
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(sessionTime) < validDuration;
  }

  /// Clear all stored session data.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keySessionTimestamp);
  }
}
