class FeedItem {
  final String workoutId; // Unique ID for the workout
  final String userId; // ID of the user who created the workout
  final String username; // Name of the user who created the workout
  final String profilePicUrl; // URL of the user's profile picture
  final String workoutTitle; // Title of the workout
  final String? notes; // Optional notes for the workout
  final Duration duration; // Duration of the workout
  final double volume; // Total volume lifted in the workout
  final int sets; // Total number of sets in the workout
  final DateTime timestamp; // Timestamp of when the workout was created
  final List<ExerciseSummary> exercises; // List of exercises (summary only)

  FeedItem({
    required this.workoutId,
    required this.userId,
    required this.username,
    required this.profilePicUrl,
    required this.workoutTitle,
    this.notes,
    required this.duration,
    required this.volume,
    required this.sets,
    required this.timestamp,
    required this.exercises,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      workoutId: json['workout_id'],
      userId: json['user_id'],
      username: json['username'],
      profilePicUrl: json['profile_pic_url'],
      workoutTitle: json['workout_title'],
      notes: json['notes'],
      duration: Duration(seconds: json['duration']),
      volume: json['volume'].toDouble(),
      sets: json['sets'],
      timestamp: DateTime.parse(json['timestamp']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExerciseSummary {
  final String name; // Name of the exercise (e.g., "Bench Press")
  final int sets; // Number of sets for the exercise
  final int reps; // Average or total reps for the exercise
  final double weight; // Average or total weight for the exercise

  ExerciseSummary({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory ExerciseSummary.fromJson(Map<String, dynamic> json) {
    return ExerciseSummary(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
    );
  }
}