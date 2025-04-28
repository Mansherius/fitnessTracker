import 'dart:async';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
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
                      // tell the parent “minimize” instead of pop
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
                  IconButton(
                    icon: const Icon(Icons.timer, color: Colors.white),
                    onPressed: () {}, // pause/resume hook
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // finish & save
                      Navigator.pop(context);
                    },
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
                        _formatDuration(_elapsed),
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

            // ── Body Placeholder ─────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fitness_center,
                        color: Colors.grey, size: 48),
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
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          // demo only
                          _totalSets += 1;
                          _totalVolume += 50;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Buttons ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // open settings here
                      },
                      child: const Text('Settings'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
}
