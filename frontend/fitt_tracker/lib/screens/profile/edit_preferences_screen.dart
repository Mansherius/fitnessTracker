import 'package:flutter/material.dart';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fitnessLevelController = TextEditingController();
  final TextEditingController _measurementsController = TextEditingController();

  @override
  void dispose() {
    _fitnessLevelController.dispose();
    _measurementsController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (_formKey.currentState!.validate()) {
      // Simulate saving preferences to the backend
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences updated successfully!')),
      );
      Navigator.pop(context); // Return to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preferences'),
      ),
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
              TextFormField(
                controller: _fitnessLevelController,
                decoration: const InputDecoration(
                  labelText: 'Fitness Level',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your fitness level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _measurementsController,
                decoration: const InputDecoration(
                  labelText: 'Measurements (e.g., weight, height)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your measurements';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreferences,
                child: const Text('Save Preferences'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}