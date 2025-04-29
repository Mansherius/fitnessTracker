import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();  
  static final ApiClient instance = ApiClient._();
  final String _baseUrl = 'http://51.20.171.163:8000';

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
      };

  /// Checks whether [email] is already registered.
  /// Returns true if the email is available.
  Future<bool> checkEmail(String email) async {
    final uri = Uri.parse('$_baseUrl/users/check-email')
        .replace(queryParameters: {'email': email});
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['available'] as bool;
    }
    throw Exception('Email check failed [${res.statusCode}]: ${res.body}');
  }

  /// Sends a signup request to `/users`.
  /// Expects the payload to match the Flask payload keys.
  Future<void> signUp(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/users');
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201) {
      throw Exception('Sign up failed [${res.statusCode}]: ${res.body}');
    }
  }

  // ... you can add other methods for login, workouts, etc.
}