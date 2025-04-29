import 'dart:convert';
import 'package:uuid/uuid.dart'; // Add this package for generating unique tokens
import 'package:fitt_tracker/utils/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final Logger _logger = Logger();
  final String _baseUrl = 'http://51.20.171.163:8000';
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Uuid _uuid = Uuid(); // For generating unique tokens

  /// Username/Password login
  Future<Map<String, String>?> signInWithUsernamePassword(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/login');
    final payload = {
      'email': email,
      'password_hash': password, // Ensure this matches the backend's expected key
    };

    try {
      _logger.i('Sending login request to $uri with payload: $payload');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      _logger.i('Received response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final userId = responseBody['user_id']; // Extract user_id from the response

        // Generate a local token
        final token = _uuid.v4(); // Generate a unique token using UUID

        // Save the session token and user ID
        await SessionManager.saveSession(token, userId);

        return {
          'token': token, // Return the generated token
          'user_id': userId, // Return the user ID
        };
      } else {
        _logger.w('Login failed: ${response.body}');
        return null;
      }
    } catch (error, stackTrace) {
      _logger.e('Username/Password sign-in error', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  /// Google Sign-In
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
          final userId = responseBody['user_id']; // Extract user ID from the backend response

          // Generate a local token
          final localToken = _uuid.v4(); // Generate a unique token using UUID

          // Save the session token and user ID
          await SessionManager.saveSession(localToken, userId);
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
