// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitt_tracker/services/profile_service.dart';
// for ExerciseSummary & WorkoutItem

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
  List<WorkoutItem> _workoutHistory = [];

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
      builder:
          (_) => Container(
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
    // Show loading spinner until we have data
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
            // ─── Header: Avatar + Username + Metrics ─────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(
                  child: Column(
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
                      // split into two lines
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
                      const SizedBox(height: 4),
                      Text(
                        "Workouts: ${_workoutHistory.length}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Centered Action Buttons ────────────────────────────────
            Center(
              child: Wrap(
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
                    onPressed:
                        () => Navigator.pushNamed(context, '/userSearch'),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Search/Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── Workout History (feed-style cards) ──────────────────────
            // ─── Workout History (feed-style cards) ──────────────────────
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
                final w = _workoutHistory[i];
                final preview = w.exercises.take(3).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to your workout detail screen:
                      Navigator.pushNamed(
                        context,
                        '/workoutDetail',
                        arguments: {'workoutId': w.workoutId},
                      );
                    },
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + timestamp row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  w.workoutTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM d, y').format(w.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Time',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      w.duration.inHours > 0
                                          ? '${w.duration.inHours}h ${w.duration.inMinutes.remainder(60)}m'
                                          : '${w.duration.inMinutes}m',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Volume',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      '${w.volumeKg.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Records',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${w.records}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Exercise previews
                            ...preview.map(
                              (e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: AssetImage(e.iconUrl),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e.setsDescription,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // “See all” link if more than 3
                            if (w.exercises.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/workoutDetail',
                                      arguments: {'workoutId': w.workoutId},
                                    );
                                  },
                                  child: Text(
                                    'See all ${w.exercises.length} exercises',
                                    style: TextStyle(
                                      color: Colors.blueAccent[200],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
