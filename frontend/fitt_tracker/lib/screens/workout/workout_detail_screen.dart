import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/services/feed_service.dart';
import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    final FeedService feedService = FeedService();

    return FutureBuilder<FeedItem>(
      future: feedService.fetchWorkoutDetail(workoutId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final workout = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(workout.workoutTitle)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notes
                if (workout.notes != null && workout.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      workout.notes!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Duration', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${workout.duration.inMinutes}m',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Volume', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${workout.volume.toStringAsFixed(1)} kg',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sets', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${workout.sets}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Exercises
                ...workout.exercises.map((exercise) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...List.generate(exercise.sets, (index) {
                        return Text(
                          'Set ${index + 1}: ${exercise.reps} reps @ ${exercise.weight}kg',
                          style: const TextStyle(color: Colors.white),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}