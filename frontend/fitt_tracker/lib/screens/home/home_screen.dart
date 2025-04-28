// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitt_tracker/services/feed_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FeedService _feedService = FeedService();
  late Future<List<FeedItem>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _feedService.fetchFeed();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${mins}min' : '${mins}min';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedItem>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final feed = snapshot.data!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: feed.length,
          itemBuilder: (context, index) {
            final item = feed[index];

            // Only show first 3 exercises in summary
            final summaryExercises = item.exercises.take(3).toList();
            final remainingCount = item.exercises.length - summaryExercises.length;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to your workout detail screen. Pass postId.
                    Navigator.pushNamed(
                      context,
                      '/workoutDetail',
                      arguments: item.postId,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: avatar + name + timestamp
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(item.profilePicUrl),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, y - h:mm a').format(item.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Workout title
                        Text(
                          item.workoutTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time', style: TextStyle(color: Colors.grey)),
                                Text(
                                  _formatDuration(item.duration),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Volume', style: TextStyle(color: Colors.grey)),
                                Text(
                                  '${item.volumeKg.toStringAsFixed(1)} kg',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Records', style: TextStyle(color: Colors.grey)),
                                Row(
                                  children: [
                                    Text(
                                      '${item.records}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.emoji_events,
                                        color: Colors.amber, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // First 3 exercises
                        ...summaryExercises.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage(e.iconUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.setsDescription,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // "See X more exercises"
                        if (remainingCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'See $remainingCount more exercises',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
