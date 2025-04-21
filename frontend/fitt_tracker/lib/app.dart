import 'package:fitt_tracker/screens/home/home_screen.dart';
import 'package:fitt_tracker/screens/profile/user_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main_screen.dart';
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
    // While waiting for session validation, display a loading indicator.
    Widget homeWidget;
    if (_isLoading) {
      homeWidget = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      // If session is valid, use MainScreen (with bottom navigation).
      // Otherwise, show the LoginScreen.
      homeWidget = _isLoggedIn ? const MainScreen() : const LoginScreen();
    }
    
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.deepPurpleAccent,             // Color for the selected item.
        unselectedItemColor: Colors.blueGrey,          // Color for unselected items.
        selectedIconTheme: IconThemeData(size: 35),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      ),
      // Use a complete routes table for deep linking.
      home: homeWidget,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        // MainScreen is now our container for logged-in users.
        '/main': (context) => const MainScreen(),
        // Optionally, deep-link routes for specific screens.
        '/home': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/userSearch': (context) => const UserSearchScreen(),

      },
      onUnknownRoute: (settings) {
        debugPrint("Unknown route: ${settings.name}");
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
