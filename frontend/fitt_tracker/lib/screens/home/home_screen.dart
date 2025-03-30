// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToWorkout(BuildContext context) {
    Navigator.pushNamed(context, '/workout');
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Friend A completed Chest Day'),
            subtitle: Text('Bench Press, Incline Bench, Flyes...'),
          ),
          ListTile(
            title: Text('You completed Leg Day'),
            subtitle: Text('Squats, Lunges, Leg Press...'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToWorkout(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is selected
        onTap: (index) {
          if (index == 1) {
            _navigateToWorkout(context);
          } else if (index == 2) {
            _navigateToProfile(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
