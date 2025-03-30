// lib/screens/workout/workout_screen.dart
import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  void _startWorkout(BuildContext context, String workoutName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Start $workoutName?'),
        content: const Text('This will track your sets and reps.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Insert workout tracking logic here
              Navigator.pop(ctx);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ['Chest & Triceps', 'Back & Biceps', 'Leg Day'];

    return Scaffold(
      appBar: AppBar(title: const Text('My Workouts')),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return ListTile(
            title: Text(workout),
            subtitle: const Text('Brief description here'),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: () => _startWorkout(context, workout),
            ),
          );
        },
      ),
    );
  }
}
