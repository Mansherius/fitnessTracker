// lib/services/feed_service.dart
import 'dart:async';

class FeedItem {
  final String postId;
  final String userId;
  final String username;
  final String profilePicUrl;
  final DateTime timestamp;
  final String workoutTitle;
  final Duration duration;
  final double volumeKg;
  final int records;
  final List<ExerciseSummary> exercises;

  FeedItem({
    required this.postId,
    required this.userId,
    required this.username,
    required this.profilePicUrl,
    required this.timestamp,
    required this.workoutTitle,
    required this.duration,
    required this.volumeKg,
    required this.records,
    required this.exercises,
  });
}

class ExerciseSummary {
  final String name;
  final String iconUrl; // or asset reference
  final String setsDescription; // e.g. "4 sets Lat Pulldown"

  ExerciseSummary({
    required this.name,
    required this.iconUrl,
    required this.setsDescription,
  });
}

class FeedService {
  /// Stub: fetches the “feed” for everyone the user follows.
  Future<List<FeedItem>> fetchFeed() async {
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data
    return [
      FeedItem(
        postId: 'post1',
        userId: 'u1',
        username: 'ishany',
        profilePicUrl: 'https://example.com/ishany.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        workoutTitle: 'Back + Rear Delt',
        duration: const Duration(hours: 1, minutes: 11),
        volumeKg: 12276.5,
        records: 4,
        exercises: [
          ExerciseSummary(
            name: 'Lat Pulldown (Cable)',
            iconUrl: 'assets/images/lat_pulldown.png',
            setsDescription: '4 sets Lat Pulldown (Cable)',
          ),
          ExerciseSummary(
            name: 'Cross-Body Cable Y-Raise',
            iconUrl: 'assets/images/y_raise.png',
            setsDescription: '3 sets Cross-Body Cable Y-Raise',
          ),
          ExerciseSummary(
            name: 'Seated Row (Machine)',
            iconUrl: 'assets/images/seated_row.png',
            setsDescription: '1 set Seated Row (Machine)',
          ),
          // ...more...
        ],
      ),

      FeedItem(
        postId: 'post2',
        userId: 'u1',
        username: 'ishany',
        profilePicUrl: 'https://example.com/ishany.png',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        workoutTitle: 'Arms',
        duration: const Duration(minutes: 53),
        volumeKg: 4818.8,
        records: 9,
        exercises: [
          ExerciseSummary(
            name: 'Preacher Curl (Barbell)',
            iconUrl: 'assets/images/preacher_curl.png',
            setsDescription: '3 sets Preacher Curl (Barbell)',
          ),
          ExerciseSummary(
            name: 'Triceps Pushdown',
            iconUrl: 'assets/images/triceps_pushdown.png',
            setsDescription: '3 sets Triceps Pushdown',
          ),
          // ...more...
        ],
      ),

      // ...more posts...
    ];
  }
}
