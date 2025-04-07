import 'package:flutter/material.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Check if a valid session exists using our SessionManager.
    bool validSession = await SessionManager.isSessionValid();
    setState(() {
      _isLoggedIn = validSession;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // While checking the session, display a loading indicator.
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // Once loading is complete, choose the initial screen based on session validity.
    return MaterialApp(
      title: 'Fitness Tracker',
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
      // Optionally, add your routes here.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // Add additional routes as needed.
      },
    );
  }
}
