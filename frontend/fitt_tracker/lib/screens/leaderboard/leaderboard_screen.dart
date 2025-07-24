import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<dynamic> leaderboardData;

  const LeaderboardScreen({super.key, required this.leaderboardData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.black,
      ),
      body: leaderboardData.isEmpty
          ? const Center(
              child: Text(
                'No leaderboard data available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final entry = leaderboardData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: entry['profile_picture_url'] != null
                        ? NetworkImage(
                            'http://51.20.171.163:8000/${entry['profile_picture_url']}')
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                  ),
                  title: Text(
                    entry['name'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Total Weight Lifted: ${entry['total_weight_lifted']} kg',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}