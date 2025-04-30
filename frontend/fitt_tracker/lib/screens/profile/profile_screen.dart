import 'package:fitt_tracker/screens/profile/edit_preferences_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/profile_service.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'package:fitt_tracker/widgets/workout_card.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  String? _fitnessLevel; // Nullable fitness level

  List<FeedItem> _workouts = []; // List to store workout details

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadWorkoutFeed();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId =
          await SessionManager.getUserId(); // Retrieve the user ID from session
      if (userId == null) {
        throw Exception('User ID cannot be null');
      }

      // Fetch profile data
      final profile = await _profileService.fetchUserProfile(userId);

      // Update state with profile data
      setState(() {
        _username = profile['username'] as String;
        _profilePicUrl = profile['profilePicUrl'] as String;
        _followersCount = profile['followersCount'] as int;
        _followingCount = profile['followingCount'] as int;
        _workoutsCount = profile['workoutsCount'] as int;
        _fitnessLevel = profile['fitnessLevel'] as String?;
      });
    } catch (e) {
      // Handle errors
      print('Error loading profile data: $e');
    }
  }

  Future<void> _loadWorkoutFeed() async {
    try {
      final userId =
          await SessionManager.getUserId(); // Retrieve the user ID from session
      if (userId == null) {
        throw Exception('User ID cannot be null');
      }

      // Fetch user workouts
      final workoutsResponse = await http.get(
        Uri.parse('http://51.20.171.163:8000/workouts/$userId'),
      );

      if (workoutsResponse.statusCode == 200) {
        final List<dynamic> workouts = jsonDecode(workoutsResponse.body);

        // Debug log to inspect the response
        print('Workouts Response: $workouts');

        // Filter out null values from the workouts list
        final filteredWorkouts =
            workouts.where((workout) => workout != null).toList();

        // Fetch details for each workout
        final List<FeedItem> workoutDetails = [];
        for (int i = 0; i < filteredWorkouts.length; i++) {
          final workout = filteredWorkouts[i];
          final workoutId = workout['id'];

          // Fetch workout details
          final detailsResponse = await http.get(
            Uri.parse('http://51.20.171.163:8000/workouts/details/$workoutId'),
          );

          if (detailsResponse.statusCode == 200) {
            final details = jsonDecode(detailsResponse.body);

            // Debug log to inspect the details
            print('Workout Details: $details');

            // Parse the date using intl
            DateTime parsedDate;
            try {
              parsedDate = DateFormat(
                "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
              ).parse(details['date']);
            } catch (e) {
              parsedDate =
                  DateTime.now(); // Fallback to current date if parsing fails
              print('Error parsing date: $e');
            }

            // Handle null exercises field
            final exercises =
                (details['exercises'] as List<dynamic>? ?? [])
                    .map<ExerciseSummary>(
                      (exercise) => ExerciseSummary(
                        name: exercise['exercise'],
                        sets: exercise['sets'],
                        reps: exercise['reps'],
                        weight: exercise['weight']?.toDouble() ?? 0.0,
                      ),
                    )
                    .toList();

            // Create FeedItem object
            workoutDetails.add(
              FeedItem(
                workoutId: workoutId,
                userId: userId,
                username: details['user_name'] ?? 'Unknown',
                profilePicUrl: details['profile_picture_url'] ?? '',
                workoutTitle: details['name'] ?? 'Workout #${i + 1}',
                notes: details['notes'] ?? '',
                duration: Duration(minutes: details['duration'] ?? 0),
                volume: details['volume']?.toDouble() ?? 0.0,
                sets: details['sets'] ?? 0,
                timestamp: parsedDate,
                exercises: exercises,
              ),
            );
          }
        }

        // Update state with workout details
        setState(() {
          _workouts = workoutDetails;
        });
      } else {
        print('Failed to load workouts: ${workoutsResponse.body}');
      }
    } catch (e) {
      print('Error loading workout feed: $e');
    }
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
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        _profilePicUrl.isNotEmpty
                            ? NetworkImage(_profilePicUrl)
                            : const AssetImage(
                                  'assets/images/default_profile.png',
                                )
                                as ImageProvider,
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
                          Text(
                            "Followers: $_followersCount",
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Following: $_followingCount",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "Workouts: $_workoutsCount",
                            style: const TextStyle(color: Colors.white),
                          ),
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
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPreferencesScreen(),
                        ),
                      );

                      // Reload profile data if preferences were updated
                      if (result == true) {
                        _loadProfileData();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Workout Feed
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
                itemBuilder: (context, index) {
                  final workout = _workouts[index];

                  return WorkoutCard(
                    item: workout,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WorkoutDetailScreen(workout: workout),
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
