// lib/screens/profile/profile_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/screens/profile/edit_preferences_screen.dart';
import 'package:fitt_tracker/screens/profile/image_picker_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_detail_screen.dart';
import 'package:fitt_tracker/services/image_picking_service.dart';
import 'package:fitt_tracker/services/profile_service.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'package:fitt_tracker/widgets/workout_card.dart';

const String baseUrl = 'http://51.20.171.163:8000';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  String _username = '';
  String _profilePicUrl = '';
  int _followersCount = 0;
  int _followingCount = 0;
  int _workoutsCount = 0;
  String? _fitnessLevel;

  List<FeedItem> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadWorkoutFeed();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User ID cannot be null');

      final profile = await _profileService.fetchUserProfile(userId);
      print('Profile Data from Backend: $profile');

      String picUrl = '';
      if (profile['profilePicUrl'] != null) {
        final picResp = await http.get(
          Uri.parse('$baseUrl/users/$userId/profile-picture'),
        );
        if (picResp.statusCode == 200) {
          final body = json.decode(picResp.body) as Map<String, dynamic>;
          picUrl = body['url'] as String;
        } else {
          debugPrint('No profile picture found: ${picResp.statusCode}');
        }
      }

      setState(() {
        _username = profile['username'] as String;
        _profilePicUrl = picUrl;
        _followersCount = profile['followersCount'] as int;
        _followingCount = profile['followingCount'] as int;
        _workoutsCount = profile['workoutsCount'] as int;
        _fitnessLevel = profile['fitnessLevel'] as String?;
      });

      debugPrint('Final Profile Picture URL: $_profilePicUrl');
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _loadWorkoutFeed() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User ID cannot be null');

      final workoutsResponse = await http.get(
        Uri.parse('$baseUrl/workouts/$userId'),
      );

      if (workoutsResponse.statusCode == 200) {
        final List<dynamic> workouts = jsonDecode(workoutsResponse.body);
        final filtered = workouts.where((w) => w != null).toList();

        final List<FeedItem> detailsList = [];
        for (var w in filtered) {
          final workoutId = w['id'] as String;
          final det = await http.get(
            Uri.parse('$baseUrl/workouts/details/$workoutId'),
          );
          if (det.statusCode != 200) continue;

          final data = jsonDecode(det.body) as Map<String, dynamic>;

          // parse date
          DateTime ts;
          try {
            ts = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
                .parse(data['date'] as String);
          } catch (_) {
            ts = DateTime.now();
          }

          // build exercises
          final exRaw = data['exercises'] as List<dynamic>? ?? [];
          final exercises = exRaw
              .map((ex) => ExerciseSummary(
                    name: ex['exercise'],
                    sets: ex['sets'],
                    reps: ex['reps'],
                    weight: (ex['weight'] as num).toDouble(),
                  ))
              .toList();

          // total sets
          final totalSets =
              exercises.fold<int>(0, (sum, ex) => sum + ex.sets);

          detailsList.add(FeedItem(
            workoutId: workoutId,
            userId: userId,
            username: data['user_name'] as String? ?? 'Unknown',
            profilePicUrl:
                data['profile_picture_url'] as String? ?? '',
            workoutTitle: data['name'] as String? ?? 'Untitled',
            notes: data['notes'] as String? ?? '',
            duration: (data['duration'] as int?) ?? 0,
            volume: (data['volume'] as num?)?.toDouble() ?? 0.0,
            sets: totalSets,
            timestamp: ts,
            exercises: exercises,
          ));
        }

        setState(() => _workouts = detailsList);
      } else {
        debugPrint('Failed to load workouts: ${workoutsResponse.body}');
      }
    } catch (e) {
      debugPrint('Error loading workout feed: $e');
    }
  }

  void _showEditPictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Change Picture'),
              onTap: () async {
                Navigator.pop(context);
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImagePickerScreen(),
                  ),
                );
                if (ok == true) _loadProfileData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Picture'),
              onTap: () async {
                Navigator.pop(context);
                final serv = ImagePickingService();
                final userId = await SessionManager.getUserId();
                if (userId == null) throw Exception();
                final ok = await serv.deleteProfilePicture(userId);
                if (ok) _loadProfileData();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_username.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // — Profile Header
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profilePicUrl.isNotEmpty
                            ? NetworkImage(_profilePicUrl)
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showEditPictureOptions,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Followers: $_followersCount",
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          Text("Following: $_followingCount",
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Workouts: $_workoutsCount",
                              style: const TextStyle(color: Colors.white)),
                          if (_fitnessLevel != null &&
                              _fitnessLevel!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                _fitnessLevel!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditPreferencesScreen(),
                        ),
                      );
                      if (ok == true) _loadProfileData();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // — Workout Feed
              const Text(
                "Workout Feed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length,
                itemBuilder: (_, i) {
                  final w = _workouts[i];
                  return WorkoutCard(
                    item: w,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutDetailScreen(workout: w),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
