import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder variables to be replaced by backend data.
  String _username = "JohnDoe";
  String _profilePicUrl = ""; // If empty, a default asset image is used.
  int _followersCount = 120;
  int _followingCount = 80;
  List<String> _workoutHistory = [
    "Chest Day",
    "Leg Day",
    "Back & Biceps",
    "Shoulders & Triceps",
  ];

  // Simulated method to load profile data from the backend.
  Future<void> _loadProfileData() async {
    // Replace with your API call.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Update these variables with the actual data from your backend.
      _username = "JohnDoe";
      _profilePicUrl = ""; // Use a network URL if available.
      _followersCount = 120;
      _followingCount = 80;
      _workoutHistory = [
        "Chest Day",
        "Leg Day",
        "Back & Biceps",
        "Shoulders & Triceps",
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Show leaderboard bottom sheet.
  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Placeholder leaderboard data.
        final List<Map<String, dynamic>> leaderboard = [
          {"username": "Alice", "score": 150},
          {"username": "Bob", "score": 140},
          {"username": "Charlie", "score": 130},
          {"username": _username, "score": 120},
        ];
        return Container(
          padding: const EdgeInsets.all(16.0),
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
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return ListTile(
                      title: Text(entry["username"]),
                      trailing: Text("Score: ${entry["score"]}"),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build the profile header widget.
  Widget _buildProfileHeader() {
    return Row(
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
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // Navigate to pending friend requests or a 'find friend' screen.
            Navigator.pushNamed(context, '/friendRequests');
          },
          icon: const Icon(Icons.person_add, color: Colors.white),
        ),
      ],
    );
  }

  // Build the workout history list.
  Widget _buildWorkoutHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Workout History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _workoutHistory.length,
          itemBuilder: (context, index) {
            final String workoutTitle = _workoutHistory[index];
            return ListTile(
              title: Text(
                workoutTitle,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Navigate to the workout details screen with the workout title.
                Navigator.pushNamed(context, '/workout', arguments: {'title': workoutTitle});
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _showLeaderboard,
            icon: const Icon(Icons.leaderboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            // Buttons for friend requests and finding friends.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to pending friend requests.
                    Navigator.pushNamed(context, '/friendRequests');
                  },
                  icon: const Icon(Icons.pending_actions),
                  label: const Text("Pending Requests"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to a 'find friend' screen.
                    Navigator.pushNamed(context, '/findFriend');
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Find a Friend"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildWorkoutHistory(),
          ],
        ),
      ),
    );
  }
}
