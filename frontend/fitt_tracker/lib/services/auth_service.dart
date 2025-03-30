import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Returns true if sign-in was successful.
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

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
