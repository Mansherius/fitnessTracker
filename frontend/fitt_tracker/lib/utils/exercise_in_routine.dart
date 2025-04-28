// lib/utils/exercise_in_routine.dart

class ExerciseInRoutine {
  final String id, name, iconUrl;
  final int sets, reps;
  final double weight;

  ExerciseInRoutine({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory ExerciseInRoutine.fromJson(Map<String, dynamic> j) =>
    ExerciseInRoutine(
      id: j['id'] as String,
      name: j['name'] as String,
      iconUrl: j['iconUrl'] as String,
      sets: j['sets'] as int,
      reps: j['reps'] as int,
      weight: (j['weight'] as num).toDouble(),
    );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'iconUrl': iconUrl,
    'sets': sets, 'reps': reps, 'weight': weight,
  };
}
