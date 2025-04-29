import 'dart:async';
import 'dart:convert';
import 'package:fitt_tracker/screens/workout/add_exercise_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitt_tracker/utils/session_manager.dart';

class EmptyWorkoutScreen extends StatefulWidget {
  const EmptyWorkoutScreen({super.key});

  @override
  State<EmptyWorkoutScreen> createState() => _EmptyWorkoutScreenState();
}

class _EmptyWorkoutScreenState extends State<EmptyWorkoutScreen> {
  Duration _elapsed = Duration.zero;
  int _totalSets = 0;
  double _totalVolume = 0.0;
  Timer? _timer;

  String? _workoutId; // Store the workout ID
  final List<Map<String, dynamic>> _exercises = []; // List of exercises in the workout

  final String _baseUrl = 'http://51.20.171.163:8000'; // Backend base URL

  @override
  void initState() {
    super.initState();
    _startWorkout(); // Start the workout when the screen loads
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startWorkout() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workouts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _workoutId = data['workout_id'];
          });
        }
      } else {
        throw Exception('Failed to start workout: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting workout: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addExercise(Map<String, dynamic> exercise) async {
    if (_workoutId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/exercises'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'workout_id': _workoutId,
          'exercise': exercise['name'],
          'sets': exercise['sets'],
          'reps': exercise['reps'],
          'weight': exercise['weight'],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _exercises.add({
              'id': data['exercise_id'],
              'name': exercise['name'],
              'sets': exercise['sets'],
              'reps': exercise['reps'],
              'weight': exercise['weight'],
              'setDetails': List.generate(
                exercise['sets'],
                (_) => {'reps': exercise['reps'], 'weight': exercise['weight']},
              ),
            });
            _totalSets += (exercise['sets'] as int);
            _totalVolume += exercise['sets'] * exercise['reps'] * exercise['weight'];
          });
        }
      } else {
        throw Exception('Failed to add exercise: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exercise: $e')),
        );
      }
    }
  }

  Future<void> _updateExercise(String exerciseId, List<Map<String, dynamic>> updatedSetDetails) async {
    try {
      final exercise = _exercises.firstWhere((e) => e['id'] == exerciseId);

      final response = await http.put(
        Uri.parse('$_baseUrl/exercises/$exerciseId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sets': updatedSetDetails.length,
          'setDetails': updatedSetDetails,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            exercise['setDetails'] = updatedSetDetails;
            exercise['sets'] = updatedSetDetails.length;
            _totalSets = _exercises.fold(0, (sum, e) => sum + (e['sets'] as int));
            _totalVolume = _exercises.fold(
              0.0,
              (sum, e) => sum +
                  e['setDetails'].fold(
                    0.0,
                    (setSum, set) => setSum + (set['reps'] * set['weight']),
                  ),
            );
          });
        }
      } else {
        throw Exception('Failed to update exercise: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating exercise: $e')),
        );
      }
    }
  }

  Future<void> _deleteSet(String exerciseId, int setIndex) async {
    try {
      final exercise = _exercises.firstWhere((e) => e['id'] == exerciseId);
      final updatedSetDetails = List<Map<String, dynamic>>.from(exercise['setDetails']);
      updatedSetDetails.removeAt(setIndex);

      await _updateExercise(exerciseId, updatedSetDetails);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting set: $e')),
        );
      }
    }
  }

  Future<void> _discardWorkout() async {
    if (_workoutId == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/workouts/$_workoutId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to discard workout: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error discarding workout: $e')),
        );
      }
    }
  }

  void _openAddExerciseScreen() async {
    final newExercise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(),
      ),
    );

    if (newExercise != null) {
      _addExercise(newExercise);
    }
  }

  void _finishWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          workoutId: _workoutId!,
          duration: _elapsed,
          totalSets: _totalSets,
          totalVolume: _totalVolume,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context, 'minimize');
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Log Workout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _finishWorkout,
                    child: const Text('Finish'),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // ── Stats Row ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text('Duration', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '${_elapsed.inMinutes}m ${_elapsed.inSeconds.remainder(60)}s',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Volume', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '${_totalVolume.toStringAsFixed(1)} kg',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Sets', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalSets',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // ── Exercise List ────────────────────────
            Expanded(
              child: _exercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.grey, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Get started',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add an exercise to start your workout',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (ctx, index) {
                        final exercise = _exercises[index];
                        return ExpansionTile(
                          title: Text(
                            exercise['name'], // Display exercise name
                            style: const TextStyle(color: Colors.white),
                          ),
                          children: List.generate(exercise['setDetails'].length, (setIndex) {
                            final set = exercise['setDetails'][setIndex];
                            return ListTile(
                              title: Text(
                                'Set ${setIndex + 1}: ${set['reps']} reps @ ${set['weight']}kg',
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final updatedSet = await _editSetDialog(set);
                                      if (updatedSet != null) {
                                        final updatedSetDetails = List<Map<String, dynamic>>.from(exercise['setDetails']);
                                        updatedSetDetails[setIndex] = updatedSet;
                                        _updateExercise(exercise['id'], updatedSetDetails);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteSet(exercise['id'], setIndex);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
            ),

            // ── Add Exercise Button ─────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _openAddExerciseScreen,
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
              ),
            ),

            // ── Bottom Buttons ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _discardWorkout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Discard Workout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _editSetDialog(Map<String, dynamic> set) async {
    final repsController = TextEditingController(text: set['reps'].toString());
    final weightController = TextEditingController(text: set['weight'].toString());

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'reps': int.tryParse(repsController.text) ?? set['reps'],
                  'weight': double.tryParse(weightController.text) ?? set['weight'],
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
