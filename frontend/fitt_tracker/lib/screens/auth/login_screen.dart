import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // Controllers for username and password login
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Handle login with username and password
  Future<void> _handleUsernamePasswordLogin() async {
    try {
      // Placeholder: Replace with actual backend call to verify username/password.
      final success = await _authService.signInWithUsernamePassword(
        _usernameController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Login failed: Invalid username or password.")),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      debugPrint("Username/Password login exception: $error");
      messenger.showSnackBar(
        const SnackBar(content: Text("An error occurred during login.")),
      );
    }
  }

  // Handle Google Sign-In (existing implementation)
  Future<void> _handleGoogleSignIn() async {
    try {
      final success = await _authService.signInWithGoogle();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Google sign-in failed.")),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      debugPrint("Google sign-in exception: $error");
      messenger.showSnackBar(
        const SnackBar(content: Text("An error occurred during Google sign-in.")),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Fitness Tracker!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Username/Password login section
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleUsernamePasswordLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Login"),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white),
              const SizedBox(height: 40),

              // Google Sign-In button
              ElevatedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up option
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
