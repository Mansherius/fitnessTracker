import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/feed_item.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final FeedItem workout;

  const WorkoutDetailScreen({super.key, required this.workout});

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
                Column(
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Duration(seconds: workout.duration).inMinutes} mins',
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                itemCount: workout.exercises.fold(0, (count, exercise) => count! + (exercise.sets)),
                itemBuilder: (context, index) {
                  int currentIndex = 0;
                  for (final exercise in workout.exercises) {
                    if (index < currentIndex + exercise.sets) {
                      final setIndex = index - currentIndex;
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${exercise.name} - Set ${setIndex + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${exercise.reps} reps @ ${exercise.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }
                    currentIndex += exercise.sets;
                  }
                  return const SizedBox.shrink(); // Fallback (shouldn't be reached)
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}