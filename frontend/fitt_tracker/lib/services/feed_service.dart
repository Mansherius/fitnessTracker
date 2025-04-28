// lib/services/feed_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a summary of a single exercise in a workout post.
class ExerciseSummary {
  final String name;
  final String iconUrl;       // e.g. "assets/images/lat_pulldown.png" or a network URL
  final String setsDescription;
  
  ExerciseSummary({
    required this.name,
    required this.iconUrl,
    required this.setsDescription,
  });

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      setsDescription: json['setsDescription'] as String,
    );
  }
}

/// Represents one feed post: who posted it, when, and workout stats.
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

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      profilePicUrl: json['profilePicUrl'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      workoutTitle: json['workoutTitle'] as String,
      duration: Duration(seconds: json['durationSeconds'] as int),
      volumeKg: (json['volumeKg'] as num).toDouble(),
      records: json['records'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Service that fetches the feed of workouts from users you follow.
class FeedService {
  /// (Will point here when you have a real backend)
  final String _baseUrl = 'https://api.yoursite.com';

  /// Returns hard-coded dummy data until your real API is ready.
  Future<List<FeedItem>> fetchFeed() async {
    // simulate network latency
    await Future.delayed(const Duration(seconds: 1));

    // ----- DUMMY DATA -----
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
          ExerciseSummary(
            name: 'Face Pull',
            iconUrl: 'assets/images/face_pull.png',
            setsDescription: '3 sets Face Pull',
          ),
          ExerciseSummary(
            name: 'Reverse Fly (Machine)',
            iconUrl: 'assets/images/reverse_fly.png',
            setsDescription: '2 sets Reverse Fly (Machine)',
          ),
          ExerciseSummary(
            name: 'Pull-Up (Weighted)',
            iconUrl: 'assets/images/pull_up.png',
            setsDescription: '5 sets Pull-Up (Weighted)',
          ),
          ExerciseSummary(
            name: 'Straight-Arm Pulldown',
            iconUrl: 'assets/images/straight_arm.png',
            setsDescription: '3 sets Straight-Arm Pulldown',
          ),
          ExerciseSummary(
            name: 'Dumbbell Rear Delt Raise',
            iconUrl: 'assets/images/rear_delt_raise.png',
            setsDescription: '3 sets Dumbbell Rear Delt Raise',
          ),
        ],
      ),
      FeedItem(
        postId: 'post2',
        userId: 'u2',
        username: 'alice',
        profilePicUrl: 'https://example.com/alice.png',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        workoutTitle: 'Arms Blast',
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
          ExerciseSummary(
            name: 'Hammer Curl',
            iconUrl: 'assets/images/hammer_curl.png',
            setsDescription: '4 sets Hammer Curl',
          ),
          ExerciseSummary(
            name: 'Overhead Triceps Extension',
            iconUrl: 'assets/images/overhead_extension.png',
            setsDescription: '3 sets Overhead Triceps Extension',
          ),
          ExerciseSummary(
            name: 'Concentration Curl',
            iconUrl: 'assets/images/concentration_curl.png',
            setsDescription: '2 sets Concentration Curl',
          ),
        ],
      ),
      FeedItem(
        postId: 'post3',
        userId: 'u3',
        username: 'bob',
        profilePicUrl: 'https://example.com/bob.png',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        workoutTitle: 'Leg Day',
        duration: const Duration(hours: 1, minutes: 30),
        volumeKg: 15400.0,
        records: 7,
        exercises: [
          ExerciseSummary(
            name: 'Squat (Barbell)',
            iconUrl: 'assets/images/squat.png',
            setsDescription: '5×5 Squat @ 120kg',
          ),
          ExerciseSummary(
            name: 'Leg Press',
            iconUrl: 'assets/images/leg_press.png',
            setsDescription: '4×12 Leg Press',
          ),
          ExerciseSummary(
            name: 'Lunge (Dumbbell)',
            iconUrl: 'assets/images/lunge.png',
            setsDescription: '3×10 Lunge (Each Leg)',
          ),
          ExerciseSummary(
            name: 'Leg Extension',
            iconUrl: 'assets/images/leg_extension.png',
            setsDescription: '3 sets Leg Extension',
          ),
          ExerciseSummary(
            name: 'Hamstring Curl',
            iconUrl: 'assets/images/hamstring_curl.png',
            setsDescription: '3 sets Hamstring Curl',
          ),
          ExerciseSummary(
            name: 'Calf Raise (Machine)',
            iconUrl: 'assets/images/calf_raise.png',
            setsDescription: '4 sets Calf Raise (Machine)',
          ),
        ],
      ),
    ];
  }

  /*
  // FUTURE: Un-comment when your API is live

  Future<List<FeedItem>> fetchFeed() async {
    final uri = Uri.parse('$_baseUrl/feed');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load feed (status ${response.statusCode})');
    }
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  */
}
