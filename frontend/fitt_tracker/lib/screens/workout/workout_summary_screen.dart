import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitt_tracker/utils/durationTime.dart';
class WorkoutSummaryScreen extends StatefulWidget {
  final String workoutId;
  final Duration duration;
  final int totalSets;
  final double totalVolume;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutId,
    required this.duration,
    required this.totalSets,
    required this.totalVolume,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final String _baseUrl = 'http://51.20.171.163:8000'; // Backend base URL
  bool _isSaving = false;

  Future<void> _saveWorkout() async {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please provide a workout name')),
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    final requestBody = jsonEncode({
      'name': nameController.text,
      'notes': notesController.text,
      'volume': widget.totalVolume,
      'duration': durationToSeconds(widget.duration), // Use helper function here
    });

    final response = await http.patch( // Changed from PUT to PATCH
      Uri.parse('$_baseUrl/workouts/${widget.workoutId}'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully!')),
        );
        Navigator.pop(context); // Close the summary screen
        Navigator.pop(context); // Close the workout screen
      }
    } else {
      throw Exception('Failed to save workout: ${response.body}');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Stats
            Text(
              'Workout Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Duration',
                  '${widget.duration.inMinutes}m ${widget.duration.inSeconds.remainder(60)}s',
                ),
                _buildStatCard(
                  'Volume',
                  '${widget.totalVolume.toStringAsFixed(1)} kg',
                ),
                _buildStatCard('Sets', '${widget.totalSets}'),
              ],
            ),
            const SizedBox(height: 16),

            // Workout Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Workout Notes
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWorkout,
                child:
                    _isSaving
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : const Text('Save Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
