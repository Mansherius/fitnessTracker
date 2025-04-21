// lib/screens/user_search_screen.dart
import 'package:flutter/material.dart';
import 'package:fitt_tracker/services/connection_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ConnectionService _service = ConnectionService();

  // Search tab state
  String _query = '';
  List<Map<String, String>> _searchResults = [];
  final Set<String> _requestedIds = {};

  // Pending tab state
  List<Map<String, String>> _pending = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPending();
  }

  Future<void> _loadPending() async {
    final list = await _service.getPendingRequests();
    if (!mounted) return;
    setState(() {
      _pending = list;
      _requestedIds.addAll(list.map((u) => u['id']!));
    });
  }

  Future<void> _onSearchChanged(String q) async {
    setState(() => _query = q);
    final results = await _service.searchUsers(q);
    if (!mounted) return;
    setState(() => _searchResults = results);
  }

  Future<void> _sendRequest(String userId) async {
    await _service.sendRequest(userId);
    if (!mounted) return;
    setState(() {
      _requestedIds.add(userId);
      // also add to pending list
      final user = _searchResults.firstWhere((u) => u['id'] == userId);
      _pending.add(user);
    });
  }

  Future<void> _cancelRequest(String userId) async {
    await _service.cancelRequest(userId);
    if (!mounted) return;
    setState(() {
      _requestedIds.remove(userId);
      _pending.removeWhere((u) => u['id'] == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Search Tab ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Search users'),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _searchResults.isEmpty && _query.isNotEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, i) {
                            final user = _searchResults[i];
                            final id = user['id']!;
                            final name = user['username']!;
                            final requested = _requestedIds.contains(id);
                            return ListTile(
                              title: Text(name),
                              trailing: ElevatedButton(
                                onPressed: requested
                                    ? null
                                    : () => _sendRequest(id),
                                child: Text(requested ? 'Requested' : 'Add'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // --- Pending Tab ---
          RefreshIndicator(
            onRefresh: _loadPending,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pending.length,
              itemBuilder: (context, i) {
                final user = _pending[i];
                final id = user['id']!;
                final name = user['username']!;
                return ListTile(
                  title: Text(name),
                  trailing: ElevatedButton(
                    onPressed: () => _cancelRequest(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Cancel'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
