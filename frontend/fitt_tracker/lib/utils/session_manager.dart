import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyAuthToken = 'authToken';
  static const _keySessionTimestamp = 'sessionTimestamp';

  // Save session details
  static Future<void> saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    await prefs.setInt(_keySessionTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  // Retrieve session details
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  // Check if session is still valid
  static Future<bool> isSessionValid({Duration validDuration = const Duration(days: 7)}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAuthToken);
    final timestamp = prefs.getInt(_keySessionTimestamp);
    if (token == null || timestamp == null) return false;

    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(sessionTime) < validDuration;
  }

  // Clear session on logout or when needed
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keySessionTimestamp);
  }
}
