// lib/services/profile_service.dart
class ProfileService {
  /// Simulate fetching the user profile.
  Future<Map<String, dynamic>> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'username': 'JohnDoe',
      'profilePicUrl': '', // leave blank to use default asset
      'followersCount': 120,
      'followingCount': 80,
    };
  }

  /// Simulate fetching the workout history.
  Future<List<String>> fetchWorkoutHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Chest Day',
      'Leg Day',
      'Back & Biceps',
      'Shoulders & Triceps',
    ];
  }

  /// Simulate fetching the leaderboard.
  Future<List<Map<String, dynamic>>> fetchLeaderboard(
      String currentUsername) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'username': 'Alice', 'score': 150},
      {'username': 'Bob', 'score': 140},
      {'username': 'Charlie', 'score': 130},
      {'username': currentUsername, 'score': 120},
    ];
  }
}
