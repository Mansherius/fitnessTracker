// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService();

  String _username = '';
  String _profilePicUrl = '';
  int _followersCount = 0;
  int _followingCount = 0;
  List<String> _workoutHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await _service.fetchUserProfile();
    final history = await _service.fetchWorkoutHistory();
    if (!mounted) return;
    setState(() {
      _username = profile['username'] as String;
      _profilePicUrl = profile['profilePicUrl'] as String;
      _followersCount = profile['followersCount'] as int;
      _followingCount = profile['followingCount'] as int;
      _workoutHistory = history;
    });
  }

  Future<void> _showLeaderboard() async {
    final leaderboard = await _service.fetchLeaderboard(_username);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (_, i) {
                  final entry = leaderboard[i];
                  return ListTile(
                    title: Text(entry['username'] as String),
                    trailing: Text("Score: ${entry['score'] as int}"),
                  );
                },
              ),
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

    final workoutsCount = _workoutHistory.length;

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Avatar + (Username + Metrics) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profilePicUrl.isNotEmpty
                      ? NetworkImage(_profilePicUrl)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Metrics wrapped to avoid overflow
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text("Followers: $_followersCount",
                              style: const TextStyle(color: Colors.white)),
                          Text("Following: $_followingCount",
                              style: const TextStyle(color: Colors.white)),
                          Text("Workouts: $workoutsCount",
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Action Buttons (Purple) ---
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: _showLeaderboard,
                  icon: const Icon(Icons.leaderboard),
                  label: const Text("Leaderboard"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/userSearch');
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Search/Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- Workout History ---
            const Text(
              "Workout History",
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
              itemCount: _workoutHistory.length,
              itemBuilder: (context, i) {
                final title = _workoutHistory[i];
                return ListTile(
                  title: Text(title,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/workout',
                    arguments: {'title': title},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
