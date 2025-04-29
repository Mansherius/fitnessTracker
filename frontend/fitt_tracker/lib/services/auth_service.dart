import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:fitt_tracker/utils/session_manager.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();
  final String _baseUrl = 'http://51.20.171.163:8000';

  /// Username/Password login
  Future<bool> signInWithUsernamePassword(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/login');
    final payload = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token']; // Assuming the backend returns a token
        await SessionManager.saveSession(token); // Save the token for future use
        return true;
      } else {
        _logger.w('Login failed: ${response.body}');
        return false;
      }
    } catch (error, stackTrace) {
      _logger.e('Username/Password sign-in error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Google sign-in
  Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Retrieve Google authentication token
        final googleAuth = await account.authentication;
        final token = googleAuth.idToken;

        // Optionally send the token to your backend for verification
        final uri = Uri.parse('$_baseUrl/google-login');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_token': token}),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final backendToken = responseBody['token']; // Token from your backend
          await SessionManager.saveSession(backendToken); // Save the backend token
          return true;
        } else {
          _logger.w('Google sign-in backend verification failed: ${response.body}');
          return false;
        }
      }
      return false;
    } catch (error, stackTrace) {
      _logger.e('Google sign-in error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await SessionManager.clearSession(); // Clear session on sign-out
    } catch (error, stackTrace) {
      _logger.e('Google sign-out error', error: error, stackTrace: stackTrace);
    }
  }
}
