import 'package:flutter/material.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'screens/profile/profile_screen.dart';

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
    bool validSession = await SessionManager.isSessionValid();
    setState(() {
      _isLoggedIn = validSession;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Choose the home widget based on loading and session state.
    Widget homeWidget;
    if (_isLoading) {
      homeWidget = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      // Either show the HomeScreen or the LoginScreen.
      homeWidget = _isLoggedIn ? const HomeScreen() : const LoginScreen();
    }
    
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      // Always provide a complete routes table.
      home: homeWidget,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onUnknownRoute: (settings) {
        debugPrint("Unknown route: ${settings.name}");
        // Redirect unknown routes to login.
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
