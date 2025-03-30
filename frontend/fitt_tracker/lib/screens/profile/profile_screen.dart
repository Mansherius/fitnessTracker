// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock data for demonstration
  final int followersCount = 120;
  final int followingCount = 80;
  final List<String> workoutHistory = const [
    'Leg Day - 03/24/2025',
    'Chest Day - 03/22/2025',
    'Back Day - 03/20/2025',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture and stats
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Changed headline6 to titleLarge
                    Text('Username', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('$followersCount followers'),
                        const SizedBox(width: 10),
                        Text('$followingCount following'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Workout History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: workoutHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(workoutHistory[index]),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to a leaderboard screen later
              },
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
