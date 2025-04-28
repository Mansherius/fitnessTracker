// lib/services/workout_session_service.dart

import 'package:flutter/material.dart';

class WorkoutSessionService {
  /// Starts (or resumes) a live workout session.
  Future<String> startSession() async {
    // In the real app you'd POST /sessions → id
    await Future.delayed(const Duration(milliseconds: 200));
    return 'session-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Saves the completed session data to the backend.
  Future<void> saveSession(String sessionId, Map<String,dynamic> data) async {
    // In the real app you'd POST /sessions/$sessionId → data
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('Saved session $sessionId → $data');
  }
}
