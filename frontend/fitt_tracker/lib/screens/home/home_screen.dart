import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/feed_service.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/widgets/workout_card.dart';
import 'package:fitt_tracker/utils/session_manager.dart';

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
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw Exception('User ID cannot be null');
    }

    setState(() {
      _feedFuture = _feedService.fetchFeed(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<FeedItem>>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No workouts to display.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final feed = snapshot.data!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: feed.length,
            itemBuilder: (context, index) {
              final item = feed[index];
              return WorkoutCard(
                item: item,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/workoutDetail',
                    arguments: item.workoutId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
