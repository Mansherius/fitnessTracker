import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:intl/intl.dart'; // For formatting the date

class WorkoutCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesPreview = item.exercises
        .take(3)
        .map((exercise) => exercise.name)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900], // Slightly darker background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!), // Light highlight
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Title
            Text(
              item.workoutTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Optional Notes Section
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Duration, Volume, Sets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Duration', _formatDuration(item.duration)),
                _buildMetric('Volume', '${item.volume.toStringAsFixed(1)} kg'),
                _buildMetric('Sets', '${item.sets}'),
              ],
            ),
            const SizedBox(height: 12),

            // Exercises Preview
            Text(
              exercisesPreview.isNotEmpty
                  ? 'Exercises: $exercisesPreview'
                  : 'No exercises available',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Workout Date
            Text(
              'Date: ${DateFormat.yMMMd().format(item.timestamp)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the duration into a human-readable format
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '$minutes min $remainingSeconds sec'
          : '$minutes min';
    } else {
      final hours = seconds ~/ 3600;
      final remainingMinutes = (seconds % 3600) ~/ 60;
      return remainingMinutes > 0
          ? '$hours hr $remainingMinutes min'
          : '$hours hr';
    }
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}