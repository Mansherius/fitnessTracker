import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitt_tracker/models/feed_item.dart';

class ProfileService {
  final String _baseUrl = 'http://51.20.171.163:8000';

  /// Fetches basic profile info.
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
  final uri = Uri.parse('$_baseUrl/users/$userId'); // Updated endpoint
  final response = await http.get(uri);

  if (response.statusCode == 404) {
    throw Exception('User profile not found (status 404)');
  }
  if (response.statusCode != 200) {
    throw Exception('Failed to load user profile (status ${response.statusCode})');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

  /// Fetches this user’s past workouts as FeedItems.
  Future<List<FeedItem>> fetchWorkoutHistory(String userId) async {
    final uri = Uri.parse('$_baseUrl/workouts/$userId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load workout history (status ${response.statusCode})');
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
