import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/routine_service.dart';
import 'package:fitt_tracker/utils/routine.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final RoutinesService _service = RoutinesService();
  late Future<List<Routine>> _routinesFuture;
  bool _showRoutines = true;

  // For the bottom‐drawer
  PersistentBottomSheetController? _bottomSheetController;
  String? _minimizedMode;         // 'empty' or 'routine'
  Routine? _minimizedRoutine;     // for routine mode

  // Scaffold key so we can showBottomSheet outside of build()
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _routinesFuture = _service.fetchMyWorkouts();
  }

  void _refresh() {
    setState(() {
      _routinesFuture = _service.fetchMyWorkouts();
    });
  }

  Future<void> _startEmptyWorkout() async {
    final result = await Navigator.pushNamed(
      context,
      '/emptyWorkout',
      arguments: {'mode': 'empty'},
    );
    if (result == 'minimize') {
      _minimizedMode = 'empty';
      _minimizedRoutine = null;
      _showDrawer();
    }
  }

  Future<void> _startRoutine(Routine r) async {
    final result = await Navigator.pushNamed(
      context,
      '/activeWorkout',
      arguments: {'mode': 'routine', 'routine': r},
    );
    if (result == 'minimize') {
      _minimizedMode = 'routine';
      _minimizedRoutine = r;
      _showDrawer();
    }
  }

  void _createNewRoutine() {
    Navigator.pushNamed(context, '/createRoutine');
  }

  void _showDrawer() {
    // Only one drawer at a time
    if (_bottomSheetController != null) return;

    _bottomSheetController = _scaffoldKey.currentState!.showBottomSheet(
      (ctx) => GestureDetector(
        onTap: () {
          // close drawer then restore
          _bottomSheetController?.close();
          _bottomSheetController = null;
          if (_minimizedMode == 'empty') {
            _startEmptyWorkout();
          } else if (_minimizedMode == 'routine' && _minimizedRoutine != null) {
            _startRoutine(_minimizedRoutine!);
          }
        },
        child: Container(
          color: Colors.grey[900],
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _minimizedMode == 'empty'
                      ? 'Empty workout in progress'
                      : '${_minimizedRoutine?.name} in progress',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_upward, color: Colors.white),
            ],
          ),
        ),
      ),
    );

    // When the user drags it down, clear our controller so we can reopen later.
    _bottomSheetController!.closed.then((_) {
      _bottomSheetController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Workout'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Routine>>(
          future: _routinesFuture,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final routines = snap.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // ─── Quick Start ───────────────────────
                const Text(
                  'Quick Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _startEmptyWorkout,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Start Empty Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Routines Header ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Routines',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _createNewRoutine,
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _showRoutines = !_showRoutines),
                  child: Row(
                    children: [
                      Icon(
                        _showRoutines ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${routines.length})',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Routine Cards ────────────────────
                if (_showRoutines)
                  for (var r in routines) _buildRoutineCard(r),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Routine r) {
    final preview = r.exercises.take(3).toList();
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(r.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (v) {/* TODO */},
            ),
          ]),
          const SizedBox(height: 8),
          for (var ex in preview)
            Text('${ex.sets}x${ex.reps} @ ${ex.weight}kg',
                style: const TextStyle(color: Colors.grey)),
          if (r.exercises.length > 3)
            TextButton(
              onPressed: () => _startRoutine(r),
              child: Text('See all ${r.exercises.length} exercises',
                  style: TextStyle(color: Colors.blueAccent[200])),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _startRoutine(r),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Start Routine'),
          ),
        ]),
      ),
    );
  }
}
