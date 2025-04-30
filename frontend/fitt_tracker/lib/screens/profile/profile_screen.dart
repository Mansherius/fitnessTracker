import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/profile_service.dart';
import 'package:fitt_tracker/widgets/workout_card.dart';
import 'package:fitt_tracker/models/feed_item.dart';
import 'package:fitt_tracker/utils/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<List<FeedItem>> _userWorkoutsFuture;

  String _username = '';
  String _profilePicUrl = '';
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
  try {
    final userId = await SessionManager.getUserId(); // Retrieve the user ID from session
    if (userId == null) {
      throw Exception('User ID cannot be null');
    }

    // Fetch profile and workout history
    final profile = await _profileService.fetchUserProfile(userId);
    final workoutsFuture = _profileService.fetchWorkoutHistory(userId);

    // Update state
    setState(() {
      _username = profile['username'] as String;
      _profilePicUrl = profile['profilePicUrl'] as String;
      _followersCount = profile['followersCount'] as int;
      _followingCount = profile['followingCount'] as int;
      _userWorkoutsFuture = workoutsFuture;
    });
  } catch (e) {
    // Handle errors
    print('Error loading profile data: $e');
    setState(() {
      _userWorkoutsFuture = Future.error('Failed to load profile data.');
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profilePicUrl.isNotEmpty
                      ? NetworkImage(_profilePicUrl)
                      : const AssetImage(
                          'assets/images/default_profile.png',
                        ) as ImageProvider,
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
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-preferences');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Workout History
            const Text(
              "Workout History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            FutureBuilder<List<FeedItem>>(
              future: _userWorkoutsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No workouts to display.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final workouts = snapshot.data!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final item = workouts[index];
                    return WorkoutCard(
                      item: item,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/workoutDetail',
                          arguments: item.workoutId,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
