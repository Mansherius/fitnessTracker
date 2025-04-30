// lib/widgets/feed_workout_card.dart

import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:intl/intl.dart';

class FeedWorkoutCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const FeedWorkoutCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exercisesPreview = item.exercises
        .take(3)
        .map((e) => e.name)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // —————— Header: Avatar + Username ——————
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: item.profilePicUrl.isNotEmpty
                      ? NetworkImage(item.profilePicUrl)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // —————— Workout Title ——————
            Text(
              item.workoutTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // —————— Optional Notes ——————
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

            // —————— Metrics Row ——————
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Duration', _formatDuration(item.duration)),
                _buildMetric('Volume', '${item.volume.toStringAsFixed(1)} kg'),
                _buildMetric('Sets', '${item.sets}'),
              ],
            ),

            const SizedBox(height: 12),

            // —————— Exercises Preview ——————
            Text(
              exercisesPreview.isNotEmpty
                  ? 'Exercises: $exercisesPreview'
                  : 'No exercises available',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // —————— Date ——————
            Text(
              'Date: ${DateFormat.yMMMd().format(item.timestamp)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return s > 0 ? '$m min $s sec' : '$m min';
    }
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return m > 0 ? '$h hr $m min' : '$h hr';
  }
}
