// lib/screens/workout/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/feed_item.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final FeedItem workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.workoutTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Name
            Text(
              workout.workoutTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Notes
            if (workout.notes != null && workout.notes!.isNotEmpty)
              Text(
                workout.notes!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            const SizedBox(height: 16),

            // Volume, Duration, Sets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Volume
                Column(
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.volume.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Duration with HH:MM:SS
                Column(
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(workout.duration),
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Sets
                Column(
                  children: [
                    const Text(
                      'Sets',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.sets}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exercises List
            const Text(
              "Exercises:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets),
                itemBuilder: (context, index) {
                  int cursor = 0;
                  for (final ex in workout.exercises) {
                    if (index < cursor + ex.sets) {
                      final setNumber = index - cursor + 1;
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${ex.name} – Set $setNumber',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${ex.reps} reps @ ${ex.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }
                    cursor += ex.sets;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
