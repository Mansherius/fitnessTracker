// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables for async validation results (false means invalid, true means valid)
  // We initialize them as false since blank is not allowed.
  bool _isUsernameAvailable = false;
  bool _isEmailAvailable = false;
  bool _isPhoneValid = false;

  // Loading state for sign-up process
  bool _isLoading = false;

  // Helper widget: returns a suffix icon based on validation result.
  Widget _buildValidationIcon(bool isValid) {
    return Icon(
      isValid ? Icons.check : Icons.close,
      color: isValid ? Colors.green : Colors.red,
    );
  }

  // Dummy backend simulation: Check if username is available.
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() => _isUsernameAvailable = false);
      return;
    }
    // Simulate a backend call delay
    bool available = await Future.delayed(const Duration(milliseconds: 500), () {
      // For demo: "admin", "user", and "test" are considered taken.
      return !(username.toLowerCase() == "admin" ||
          username.toLowerCase() == "user" ||
          username.toLowerCase() == "test");
    });
    setState(() => _isUsernameAvailable = available);
  }

  // Dummy backend simulation: Check if email is available.
  Future<void> _checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      setState(() => _isEmailAvailable = false);
      return;
    }
    bool available = await Future.delayed(const Duration(milliseconds: 500), () {
      // For demo: "example@example.com" is already in use.
      return !(email.toLowerCase() == "example@example.com");
    });
    setState(() => _isEmailAvailable = available);
  }

  // Dummy validation: Check if phone number is valid.
  Future<void> _checkPhoneValidity(String phone) async {
    if (phone.isEmpty) {
      setState(() => _isPhoneValid = false);
      return;
    }
    // For demo: phone number is valid if it has exactly 10 digits.
    bool valid = RegExp(r'^\d{10}$').hasMatch(phone);
    // Simulate a small delay as if checking with a backend.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isPhoneValid = valid);
  }

  // Function to open a date picker for DOB selection
  Future<void> _selectDate() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  // Function to handle sign up
  Future<void> _handleSignUp() async {
    // Ensure all async validations are up-to-date.
    await _checkUsernameAvailability(_usernameController.text);
    await _checkEmailAvailability(_emailController.text);
    await _checkPhoneValidity(_phoneController.text);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // API call placeholder:
      // final response = await AuthService.signUp(
      //   name: _nameController.text,
      //   username: _usernameController.text,
      //   dob: _dobController.text,
      //   email: _emailController.text,
      //   phone: _phoneController.text,
      //   password: _passwordController.text,
      // );
      // Handle the response accordingly.

      // Simulate a short wait time (e.g., network call delay)
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when no longer needed
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of allowed email domains.
    const allowedDomains = ["@gmail.com", "@yahoo.com", "@hotmail.com"];

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Username Field with validation icon and async check on change.
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: const OutlineInputBorder(),
                  suffixIcon: _buildValidationIcon(_isUsernameAvailable),
                ),
                onChanged: (value) => _checkUsernameAvailability(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a username";
                  }
                  if (!_isUsernameAvailable) {
                    return "Username is taken";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date of Birth Field (read-only with date picker)
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select your date of birth";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Field with async validation check and allowed domain check.
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email ID",
                  border: const OutlineInputBorder(),
                  suffixIcon: _buildValidationIcon(_isEmailAvailable),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _checkEmailAvailability(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  // Basic email pattern check.
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  // Check that email ends with an allowed domain.
                  bool validDomain = allowedDomains.any(
                    (domain) => value.toLowerCase().endsWith(domain),
                  );
                  if (!validDomain) {
                    return "Email must end with one of: ${allowedDomains.join(", ")}";
                  }
                  if (!_isEmailAvailable) {
                    return "Email is already in use";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone Number Field with validation icon.
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: const OutlineInputBorder(),
                  suffixIcon: _buildValidationIcon(_isPhoneValid),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _checkPhoneValidity(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  if (!_isPhoneValid) {
                    return "Phone number is invalid";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password Field.
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please set a password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Sign Up Button or Loading Indicator.
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleSignUp,
                      child: const Text("Sign Up"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
