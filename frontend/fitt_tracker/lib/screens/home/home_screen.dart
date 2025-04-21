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
        final feed = snapshot.data!;
        // Sort newest first
        feed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // leave room for nav bar
          itemCount: feed.length,
          itemBuilder: (context, index) {
            final item = feed[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  backgroundColor: Colors.grey[850],
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            NetworkImage(item.profilePicUrl),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMM d, y – h:mm a')
                                .format(item.timestamp),
                            style: TextStyle(
                              color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: [
                    // Workout header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.workoutTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Time', style: TextStyle(color: Colors.grey)),
                            Text(_formatDuration(item.duration),
                              style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Volume', style: TextStyle(color: Colors.grey)),
                            Text('${item.volumeKg.toStringAsFixed(1)} kg',
                              style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Records', style: TextStyle(color: Colors.grey)),
                            Row(
                              children: [
                                Text('${item.records}',
                                  style: const TextStyle(color: Colors.white)),
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

                    // Exercise summary
                    ...item.exercises.map((e) {
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
                    }).toList(),

                    // “See X more…” if collapsed (but with ExpansionTile it’s automatic)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
