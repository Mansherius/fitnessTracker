// lib/services/connection_service.dart
class ConnectionService {
  /// Simulate searching users by username query.
  Future<List<Map<String, String>>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Dummy data
    final allUsers = [
      {'id': '1', 'username': 'Alice'},
      {'id': '2', 'username': 'Bob'},
      {'id': '3', 'username': 'Charlie'},
      {'id': '4', 'username': 'David'},
    ];
    if (query.isEmpty) return [];
    return allUsers
        .where((u) =>
            u['username']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Simulate sending a connection request.
  Future<void> sendRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app you'd POST to your backend here
  }

  /// Simulate fetching pending outgoing requests.
  Future<List<Map<String, String>>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Dummy pending requests
    return [
      {'id': '2', 'username': 'Bob'},
      {'id': '4', 'username': 'David'},
    ];
  }

  /// Simulate cancelling a pending request.
  Future<void> cancelRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app you'd DELETE on your backend here
  }
}
