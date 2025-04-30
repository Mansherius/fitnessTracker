// lib/services/feed_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/utils/session_manager.dart';

const String _baseUrl = 'http://51.20.171.163:8000';

class FeedService {
  /// Fetches your own workouts plus everyone you follow,
  /// sorted newest→oldest by the workout’s reported date.
  Future<List<FeedItem>> fetchFollowedAndOwnWorkouts() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw Exception('No user; cannot load feed');
    }

    // 1) load who you follow
    final followRes = await http.get(
      Uri.parse('$_baseUrl/users/$userId/following'),
    );
    if (followRes.statusCode != 200) {
      throw Exception('Could not load following list (${followRes.statusCode})');
    }
    final rawFollow = jsonDecode(followRes.body);
    final followList = rawFollow is List ? rawFollow : <dynamic>[];
    final followeeIds = followList
        .map<String?>((e) => (e is List && e.isNotEmpty) ? e[0] as String : null)
        .whereType<String>()
        .toList();

    // 2) include self
    final userIds = <String>[userId, ...followeeIds];

    final dateFmt = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
    final items = <FeedItem>[];

    // 3) for each user, fetch workouts & details
    for (final uid in userIds) {
      final wkRes = await http.get(Uri.parse('$_baseUrl/workouts/$uid'));
      if (wkRes.statusCode != 200) continue;

      final rawWk = jsonDecode(wkRes.body);
      final wkList = rawWk is List ? rawWk : <dynamic>[];

      for (final w in wkList) {
        if (w is! Map<String, dynamic>) continue;
        final workoutId = w['id'] as String?;
        if (workoutId == null) continue;

        final detRes = await http.get(
          Uri.parse('$_baseUrl/workouts/details/$workoutId'),
        );
        if (detRes.statusCode != 200) continue;

        final rawData = jsonDecode(detRes.body);
        if (rawData is! Map<String, dynamic>) continue;
        final data = rawData;

        // parse date || created_at || now
        DateTime ts;
        final dateStr = data['date'] as String?;
        if (dateStr != null) {
          try {
            ts = dateFmt.parse(dateStr);
          } catch (_) {
            ts = DateTime.now();
          }
        } else {
          final created = data['created_at'] as String?;
          ts = DateTime.tryParse(created ?? '') ?? DateTime.now();
        }

        // build exercises list
        final rawEx = data['exercises'];
        final exList = rawEx is List ? rawEx : <dynamic>[];
        final exercises = exList
            .whereType<Map<String, dynamic>>()
            .map((ex) {
              final name = ex['exercise'] as String?;
              final sets = ex['sets'] as int?;
              final reps = ex['reps'] as int?;
              final weight = (ex['weight'] as num?)?.toDouble();
              if (name == null || sets == null || reps == null || weight == null) {
                return null;
              }
              return ExerciseSummary(
                name: name,
                sets: sets,
                reps: reps,
                weight: weight,
              );
            })
            .whereType<ExerciseSummary>()
            .toList();

        final totalSets = exercises.fold<int>(0, (s, e) => s + e.sets);
        final totalVol = exercises.fold<double>(
            0, (v, e) => v + e.sets * e.reps * e.weight);

        // 4) fetch the real presigned URL for profile pic
        String picUrl = '';
        final picRes = await http.get(
          Uri.parse('$_baseUrl/users/$uid/profile-picture'),
        );
        if (picRes.statusCode == 200) {
          final m = jsonDecode(picRes.body);
          if (m is Map<String, dynamic> && m['url'] is String) {
            picUrl = m['url'] as String;
          }
        }

        items.add(FeedItem(
          workoutId:     data['id']        as String,
          userId:        data['user_id']   as String? ?? uid,
          username:      data['user_name'] as String? ?? 'Unknown',
          profilePicUrl: picUrl,
          workoutTitle:  data['name']      as String? ?? 'Untitled',
          notes:         data['notes']     as String? ?? '',
          duration:      data['duration'] is int
                            ? data['duration'] as int
                            : totalSets * 30,
          volume:        totalVol,
          sets:          totalSets,
          timestamp:     ts,
          exercises:     exercises,
        ));
      }
    }

    // 5) sort newest-first
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
}
