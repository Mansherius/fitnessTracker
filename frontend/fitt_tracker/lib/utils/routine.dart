// lib/utils/routine.dart
import 'exercise_in_routine.dart';

/// A saved workout “routine” with a list of exercises.
class Routine {
  final String id;
  final String name;
  final List<ExerciseInRoutine> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseInRoutine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
