// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/feed_service.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/widgets/feed_workout_card.dart';
import 'package:fitt_tracker/screens/workout/workout_detail_screen.dart';

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
    _feedFuture = _feedService.fetchFollowedAndOwnWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<FeedItem>>(
        future: _feedFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final feed = snap.data ?? [];

          if (feed.isEmpty) {
            return const Center(
              child: Text(
                'No workouts to display.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Make sure they're newest→oldest
          feed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: feed.length,
            itemBuilder: (context, i) {
              final item = feed[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(workout: item),
                    ),
                  );
                },
                child: FeedWorkoutCard(
                  item: item,
                  // you can still forward the tap if you like:
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
