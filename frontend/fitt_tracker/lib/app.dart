import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/screens/profile/edit_preferences_screen.dart';
import 'package:fitt_tracker/screens/workout/activeWorkout.dart';
import 'package:fitt_tracker/screens/workout/create_routine_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitt_tracker/screens/auth/login_screen.dart';
import 'package:fitt_tracker/screens/auth/signup_screen.dart';
import 'package:fitt_tracker/screens/main_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_screen.dart';
import 'package:fitt_tracker/screens/profile/profile_screen.dart';
import 'package:fitt_tracker/screens/profile/user_search_screen.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'screens/workout/empty_workout_screen.dart';

/// Disable the Android overscroll glow everywhere.
class NoGlowScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
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
    // Decide which screen to show while loading / after session check:
    Widget homeWidget;
    if (_isLoading) {
      homeWidget = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      homeWidget =
          _isLoggedIn ? const MainScreen() : const LoginScreen();
    }

    return MaterialApp(
      title: 'Lit Fitt',
      scrollBehavior: NoGlowScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.blueGrey,
          selectedIconTheme: IconThemeData(size: 35),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: homeWidget,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/main': (context) => const MainScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/userSearch': (context) => const UserSearchScreen(),
        '/activeWorkout': (context) => const ActiveWorkoutScreen(),
        '/emptyWorkout': (_) => const EmptyWorkoutScreen(),
        '/createRoutine': (context) => const CreateRoutineScreen(),
        '/edit-preferences': (context) => const EditPreferencesScreen(),
        '/workoutDetail': (context) => WorkoutDetailScreen(
          workout: ModalRoute.of(context)!.settings.arguments as FeedItem,
        ),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}
