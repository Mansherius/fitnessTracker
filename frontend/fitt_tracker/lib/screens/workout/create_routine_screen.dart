// lib/screens/workout/create_routine_screen.dart

import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/routine_service.dart';
import 'package:fitt_tracker/models/routine.dart';
import 'package:fitt_tracker/models/exercise_in_routine.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<ExerciseInRoutine> _exercises = [];

  final _service = RoutinesService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Adds a new empty exercise placeholder.
  void _addExercise() {
    setState(() {
      _exercises = List.from(_exercises)
        ..add(ExerciseInRoutine(
          id: DateTime.now().toIso8601String(),
          name: 'New Exercise',
          iconUrl: 'assets/images/default_exercise.png',
          sets: 3,
          reps: 10,
          weight: 20.0,
        ));
    });
  }

  /// Edits one exercise, replacing it immutably.
  void _editExercise(int index) async {
    final old = _exercises[index];
    // For demo: simple dialog to change sets/reps/weight:
    final result = await showDialog<ExerciseInRoutine>(
      context: context,
      builder: (ctx) {
        final setsCtrl = TextEditingController(text: old.sets.toString());
        final repsCtrl = TextEditingController(text: old.reps.toString());
        final weightCtrl = TextEditingController(text: old.weight.toString());
        return AlertDialog(
          title: const Text('Edit Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(old.name),
              TextField(
                controller: setsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
              TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final updated = ExerciseInRoutine(
                  id: old.id,
                  name: old.name,
                  iconUrl: old.iconUrl,
                  sets: int.tryParse(setsCtrl.text) ?? old.sets,
                  reps: int.tryParse(repsCtrl.text) ?? old.reps,
                  weight: double.tryParse(weightCtrl.text) ?? old.weight,
                );
                Navigator.pop(ctx, updated);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _exercises = List.from(_exercises)
          ..[index] = result;
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;
    final newRoutine = Routine(
      id: DateTime.now().toIso8601String(),
      name: _nameController.text.trim(),
      exercises: _exercises,
    );
    await _service.createRoutine(newRoutine);
    Navigator.pop(context, newRoutine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Routine name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Routine Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 24),

                // Exercises
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Exercises',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: _exercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _exercises.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final ex = _exercises[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(ex.iconUrl),
                              ),
                              title: Text(ex.name),
                              subtitle: Text(
                                  '${ex.sets}×${ex.reps} @ ${ex.weight}kg'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editExercise(i),
                              ),
                            );
                          },
                        ),
                ),

                // Add new exercise
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
