import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fitnessLevelController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();

  bool _hasUpdated = false; // Track if any updates were made

  @override
  void dispose() {
    _fitnessLevelController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    super.dispose();
  }

  Future<void> _updateFitnessLevel() async {
    if (_fitnessLevelController.text.isNotEmpty) {
      try {
        final userId = await _getUserId(); // Retrieve the user ID
        final response = await _updateFitnessLevelRequest(
          userId: userId,
          fitnessLevel: _fitnessLevelController.text,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitness level updated successfully!')),
          );
          _hasUpdated = true; // Mark as updated
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update fitness level: ${response.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateMeasurements() async {
    if (_weightController.text.isNotEmpty ||
        _bmiController.text.isNotEmpty ||
        _bodyFatController.text.isNotEmpty ||
        _muscleMassController.text.isNotEmpty) {
      try {
        final measurementId = await _getMeasurementId(); // Retrieve the measurement ID
        final response = await _updateMeasurementsRequest(
          measurementId: measurementId,
          weight: _weightController.text,
          bmi: _bmiController.text,
          bodyFatPercentage: _bodyFatController.text,
          muscleMass: _muscleMassController.text,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Measurements updated successfully!')),
          );
          _hasUpdated = true; // Mark as updated
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update measurements: ${response.body}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String> _getUserId() async {
    // Simulate retrieving the user ID from session or storage
    // Replace this with your actual implementation
    return 'mock_user_id';
  }

  Future<String> _getMeasurementId() async {
    // Simulate retrieving the measurement ID
    // Replace this with your actual implementation
    return 'mock_measurement_id';
  }

  Future<http.Response> _updateFitnessLevelRequest({
  required String userId,
  required String fitnessLevel,
}) async {
  final url = Uri.parse('http://51.20.171.163:8000/users/$userId');
  final body = jsonEncode({
    'user_id': userId, // Include user_id in the payload
    'fitness_level': fitnessLevel,
  });

  print('Sending request to $url with body: $body'); // Debug log

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  print('Response: ${response.statusCode}, ${response.body}'); // Debug log
  return response;
}

  Future<http.Response> _updateMeasurementsRequest({
    required String measurementId,
    required String weight,
    required String bmi,
    required String bodyFatPercentage,
    required String muscleMass,
  }) async {
    final url = Uri.parse('http://51.20.171.163:8000/measurements/$measurementId');
    final body = jsonEncode({
      'weight': weight,
      'bmi': bmi,
      'body_fat_percentage': bodyFatPercentage,
      'muscle_mass': muscleMass,
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Update Your Preferences',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Fitness Level Input
              TextFormField(
                controller: _fitnessLevelController,
                decoration: const InputDecoration(
                  labelText: 'Fitness Level',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Measurements Inputs
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bmiController,
                decoration: const InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bodyFatController,
                decoration: const InputDecoration(
                  labelText: 'Body Fat Percentage (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _muscleMassController,
                decoration: const InputDecoration(
                  labelText: 'Muscle Mass (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Update Fitness Level Button
              ElevatedButton(
                onPressed: _updateFitnessLevel,
                child: const Text('Update Fitness Level'),
              ),
              const SizedBox(height: 20),

              // Update Measurements Button
              ElevatedButton(
                onPressed: _updateMeasurements,
                child: const Text('Update Measurements'),
              ),
              const SizedBox(height: 20),

              // Save and Exit Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _hasUpdated); // Return whether updates were made
                },
                child: const Text('Save and Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
