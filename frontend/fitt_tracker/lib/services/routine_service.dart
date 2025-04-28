// lib/services/routine_service.dart

import 'dart:async';
import 'package:fitt_tracker/models/routine.dart';
import 'package:fitt_tracker/models/exercise_in_routine.dart';

/// Stubbed service for loading and mutating the user’s saved routines.
class RoutinesService {
  /// Simulates fetching the list of routines from your backend.
  Future<List<Routine>> fetchMyWorkouts() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Routine(
        id: 'r1',
        name: 'Push Day',
        exercises: [
          ExerciseInRoutine(
            id: 'e1',
            name: 'Bench Press',
            iconUrl: 'assets/images/bench_press.png',
            sets: 5,
            reps: 5,
            weight: 100.0,
          ),
          ExerciseInRoutine(
            id: 'e2',
            name: 'Overhead Press',
            iconUrl: 'assets/images/ohp.png',
            sets: 4,
            reps: 8,
            weight: 60.0,
          ),
        ],
      ),
      Routine(
        id: 'r2',
        name: 'Pull Day',
        exercises: [
          ExerciseInRoutine(
            id: 'e3',
            name: 'Pull-Up',
            iconUrl: 'assets/images/pull_up.png',
            sets: 5,
            reps: 5,
            weight: 0.0,
          ),
          ExerciseInRoutine(
            id: 'e4',
            name: 'Barbell Row',
            iconUrl: 'assets/images/row.png',
            sets: 4,
            reps: 8,
            weight: 80.0,
          ),
        ],
      ),
      // …add more Routines here as needed…
    ];
  }

  /// Simulates creating a new routine on your backend.
  Future<void> createRoutine(Routine routine) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: send HTTP POST to your API
    print('🔄 createRoutine: ${routine.name} with ${routine.exercises.length} exercises');
  }

  /// Simulates updating an existing routine.
  Future<void> updateRoutine(Routine routine) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: send HTTP PUT/PATCH to your API
    print('🔄 updateRoutine: ${routine.id} → ${routine.name}');
  }

  /// Simulates deleting a routine by its id.
  Future<void> deleteRoutine(String routineId) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: send HTTP DELETE to your API
    print('🔄 deleteRoutine: $routineId');
  }
}
