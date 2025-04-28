// lib/screens/auth/signup_screen.dart
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

  // Async validation flag for email uniqueness
  bool _isEmailAvailable = false;

  // Loading state
  bool _isLoading = false;

  Future<void> _checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      setState(() => _isEmailAvailable = false);
      return;
    }
    bool available = await Future.delayed(
      const Duration(milliseconds: 500),
      () => email.toLowerCase() != 'taken@example.com',
    );
    setState(() => _isEmailAvailable = available);
  }

  Future<void> _submitToBackend(Map<String, dynamic> payload) async {
    debugPrint('Sign-up payload: $payload');
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _handleSignUp() async {
    await _checkEmailAvailability(_emailController.text.trim());

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

    await _submitToBackend(payload);

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
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

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  suffixIcon: Icon(
                    _isEmailAvailable ? Icons.check : Icons.close,
                    color: _isEmailAvailable ? Colors.green : Colors.red,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: _checkEmailAvailability,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  if (!_isEmailAvailable) return 'Email already in use';
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
