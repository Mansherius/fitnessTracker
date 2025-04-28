// lib/services/profile_service.dart

import 'dart:async';
import 'package:fitt_tracker/services/feed_service.dart'; // for ExerciseSummary

/// Represents one completed workout from *this* user.
class WorkoutItem {
  final String workoutId;
  final String workoutTitle;
  final DateTime timestamp;
  final Duration duration;
  final double volumeKg;
  final int records;
  final List<ExerciseSummary> exercises;

  WorkoutItem({
    required this.workoutId,
    required this.workoutTitle,
    required this.timestamp,
    required this.duration,
    required this.volumeKg,
    required this.records,
    required this.exercises,
  });
}

class ProfileService {
  /// Fetches basic profile info.
  Future<Map<String, Object>> fetchUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'username': 'JohnDoe',
      'profilePicUrl': '',
      'followersCount': 120,
      'followingCount': 80,
    };
  }

  /// Fetches this user’s past workouts.
  Future<List<WorkoutItem>> fetchWorkoutHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    // Dummy data reusing ExerciseSummary from feed_service
    return [
      WorkoutItem(
        workoutId: 'w1',
        workoutTitle: 'Leg Day',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(hours: 1),
        volumeKg: 5000,
        records: 2,
        exercises: [
          ExerciseSummary(
            name: 'Squat',
            iconUrl: 'assets/images/squat.png',
            setsDescription: '4×5 Squat @ 100kg',
          ),
          ExerciseSummary(
            name: 'Leg Press',
            iconUrl: 'assets/images/leg_press.png',
            setsDescription: '3×10 Leg Press @ 200kg',
          ),
          ExerciseSummary(
            name: 'Lunge',
            iconUrl: 'assets/images/lunge.png',
            setsDescription: '3×12 Lunge @ bodyweight',
          ),
          // …etc.
        ],
      ),
      // …more WorkoutItem…
    ];
  }

  /// Fetches leaderboard entries relative to this user.
  Future<List<Map<String, Object>>> fetchLeaderboard(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'username': 'Alice', 'score': 150},
      {'username': 'Bob', 'score': 140},
      {'username': username, 'score': 120},
    ];
  }
}
