import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Returns true if Google sign-in was successful.
  Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Here you could also save user details, update state, etc.
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      _logger.e('Google sign-in error', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Returns true if username/password login is successful.
  Future<bool> signInWithUsernamePassword(String username, String password) async {
    try {
      // Simulate network delay.
      await Future.delayed(const Duration(seconds: 1));
      // For demo purposes, we simply check if both values are "test".
      if (username == "test" && password == "test") {
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
      // For demo purposes, we'll assume the sign-up always succeeds.
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
