// lib/screens/auth/signup_screen.dart
import 'package:fitt_tracker/api/api_client.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the required fields
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController      = TextEditingController();
  final TextEditingController _genderController   = TextEditingController();

  // Allowed gender options
  static const List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
  ];

  // Loading state
  bool _isLoading = false;

  Future<void> _submitToBackend(Map<String, dynamic> payload) async {
    try {
      await ApiClient.instance.signUp(payload);
      debugPrint('Sign-up successful');
    } catch (e) {
      debugPrint('Sign-up failed: $e');
      throw Exception('Failed to sign up');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now().toIso8601String();
    final payload = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password_hash': _passwordController.text,
      'age': int.parse(_ageController.text.trim()),
      'gender': _genderController.text.trim(),
      'created_at': now,
      'updated_at': now,
    };

    try {
      await _submitToBackend(payload);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // no back arrow
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Email (no availability check)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please set a password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your age';
                  final age = int.tryParse(v);
                  if (age == null || age < 12 || age > 100) {
                    return 'Age must be between 12 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender with autocomplete suggestions
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _genderOptions.where((opt) {
                    return opt.toLowerCase().startsWith(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (String selection) {
                  _genderController.text = selection;
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onSubmitted) {
                  textController.text = _genderController.text;
                  return TextFormField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      hintText: 'Male, Female, or Other',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) => onSubmitted(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your gender';
                      if (!_genderOptions.contains(v.trim())) {
                        return 'Must be: Male, Female or Other';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Submit
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Sign Up'),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
