// lib/services/feed_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed_item.dart';

class FeedService {
  final String _baseUrl = 'http://51.20.171.163:8000';

  Future<List<FeedItem>> fetchFeed(String userId) async {
    final uri = Uri.parse('$_baseUrl/feed/$userId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load feed (status ${response.statusCode})');
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FeedItem> fetchWorkoutDetail(String workoutId) async {
    final uri = Uri.parse('$_baseUrl/workouts/details/$workoutId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load workout details (status ${response.statusCode})');
    }

    return FeedItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> markWorkoutAsViewed(String viewerId, String workoutId) async {
    final uri = Uri.parse('$_baseUrl/feed/viewed');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'viewer_id': viewerId,
        'workout_id': workoutId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark workout as viewed (status ${response.statusCode})');
    }
  }
}
