import 'package:fitt_tracker/screens/profile/edit_preferences_screen.dart';
import 'package:fitt_tracker/screens/workout/workout_detail_screen.dart';
import 'package:fitt_tracker/screens/profile/image_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/profile_service.dart';
import 'package:fitt_tracker/services/image_picking_service.dart';
import 'package:fitt_tracker/utils/session_manager.dart';
import 'package:fitt_tracker/widgets/workout_card.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Define the base URL for your API
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

      // instead of constructing the image URL yourself...
      String picUrl = '';
      if (profile['profilePicUrl'] != null) {
        // call the Flask endpoint that returns {"url": "..."}
        final picResp = await http.get(
          Uri.parse('$baseUrl/users/$userId/profile-picture'),
        );
        if (picResp.statusCode == 200) {
          final body = json.decode(picResp.body) as Map<String, dynamic>;
          picUrl = body['url'] as String;
        } else {
          print('No profile picture found: ${picResp.statusCode}');
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

      print('Final Profile Picture URL: $_profilePicUrl');
    } catch (e) {
      debugPrint('Error loading profile data: $e');
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
                duration: details['duration'] ?? 0,
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

  void _showEditPictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Change Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePickerScreen(),
                    ),
                  );

                  // Reload profile picture if updated
                  if (result == true) {
                    _loadProfileData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePickingService = ImagePickingService();
                  final userId = await SessionManager.getUserId();
                  if (userId == null) throw Exception('User ID cannot be null');
                  final success = await imagePickingService
                      .deleteProfilePicture(userId);
                  if (success) {
                    _loadProfileData();
                  } else {
                    debugPrint('Failed to delete profile picture');
                  }
                },
              ),
            ],
          ),
        );
      },
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
              // Profile Header
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            (_profilePicUrl.isNotEmpty)
                                ? NetworkImage(_profilePicUrl)
                                : const AssetImage(
                                      'assets/images/default_profile.png',
                                    )
                                    as ImageProvider,
                      ),
                      Positioned(
                        top: 0, // Move to the top
                        right: 0, // Align to the right
                        child: GestureDetector(
                          onTap: _showEditPictureOptions,
                          child: Container(
                            padding: const EdgeInsets.all(
                              4,
                            ), // Add padding for better touch area
                            decoration: BoxDecoration(
                              color:
                                  Colors
                                      .lightBlue, // Background color for the button
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16, // Smaller icon size
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
