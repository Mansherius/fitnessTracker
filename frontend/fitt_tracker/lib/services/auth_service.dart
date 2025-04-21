import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:fitt_tracker/utils/session_manager.dart'; // Make sure to import your session manager

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Returns true if Google sign-in was successful.
  Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Optionally retrieve and store an authentication token
        // Here, for testing purposes, we simply save a dummy token.
        await SessionManager.saveSession("dummy_google_token");
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      _logger.e('Google sign-in error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Temporary username/password login for testing.
  Future<bool> signInWithUsernamePassword(String username, String password) async {
    try {
      // Simulate network delay.
      await Future.delayed(const Duration(seconds: 1));
      // For testing, only accept "test" for both username and password.
      if (username == "test" && password == "test") {
        // Save a dummy token into your session.
        await SessionManager.saveSession("dummy_token");
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      _logger.e('Username/Password sign-in error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Simulate a sign-up method.
  Future<bool> signUp({
    required String name,
    required String username,
    required String dob,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Simulate a network call delay.
      await Future.delayed(const Duration(seconds: 2));
      // For testing, we'll assume sign-up always succeeds and saves a session.
      await SessionManager.saveSession("dummy_signup_token");
      return true;
    } catch (error, stackTrace) {
      _logger.e('Sign-up error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      _logger.e('Google sign-out error', error: error, stackTrace: stackTrace);
    }
  }
}
