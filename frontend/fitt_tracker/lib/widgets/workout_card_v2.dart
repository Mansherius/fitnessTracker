import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/feed_item.dart';

class WorkoutCardV2 extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const WorkoutCardV2({super.key, required this.item, required this.onTap});

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
            // User Info Row (New Section)
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: item.profilePicUrl.isNotEmpty
                      ? NetworkImage(item.profilePicUrl)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(
                  item.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                _buildMetric('Duration', '${item.duration.inMinutes} min'),
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
          ],
        ),
      ),
    );
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