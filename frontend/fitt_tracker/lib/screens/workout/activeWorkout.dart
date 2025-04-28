// lib/screens/workout/active_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:fitt_tracker/models/routine.dart';
import 'package:fitt_tracker/models/exercise_in_routine.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late String mode;
  Routine? routine;
  late DateTime startTime;
  late List<ExerciseInRoutine> exercises;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    mode = args['mode'] as String;
    if (mode == 'routine') {
      routine = args['routine'] as Routine;
      exercises = List<ExerciseInRoutine>.from(routine!.exercises);
    } else {
      exercises = [];
    }
    startTime = DateTime.now();
  }

  Duration get elapsed => DateTime.now().difference(startTime);
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
  double get totalVolume =>
      exercises.fold(0.0, (sum, e) => sum + e.sets * e.reps * e.weight);

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _discard() {
    Navigator.pop(context);
  }

  void _finish() {
    // TODO: save workout
    Navigator.pop(context);
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _addExercise() {
    Navigator.pushNamed(context, '/addExercise');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context, 'minimize');
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Active Workout',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Finish',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // ─── Metrics Row ────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricTile(label: 'Time', value: _formatTime(elapsed)),
                  _MetricTile(
                      label: 'Volume', value: '${totalVolume.toStringAsFixed(0)}kg'),
                  _MetricTile(label: 'Sets', value: '$totalSets'),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // ─── Exercise List & Add Button ─────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (exercises.isEmpty) ...[
                    const SizedBox(height: 48),
                    const Center(
                      child: Text(
                        'No exercises yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  for (var ex in exercises) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(ex.iconUrl),
                      ),
                      title: Text(ex.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${ex.sets}×${ex.reps} @${ex.weight}kg',
                          style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // TODO: edit exercise
                        },
                      ),
                    ),
                    const Divider(color: Colors.grey),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ─── Bottom Controls ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openSettings,
                      child: const Text('Settings',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _discard,
                      child: const Text('Discard',
                          style: TextStyle(color: Colors.red)),
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
}

class _MetricTile extends StatelessWidget {
  final String label, value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
