import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/wellness_session.dart';
import 'api_client.dart';

class WellnessApiService {
  final ApiClient _apiClient;
  
  WellnessApiService({BuildContext? context}) : _apiClient = ApiClient(context: context);

  bool get isAuthenticated => _apiClient.isAuthenticated;

  // Map frontend enum to backend enum values
  String _mapSessionType(WellnessSessionType type) {
    switch (type) {
      case WellnessSessionType.meditation:
        return 'meditation';
      case WellnessSessionType.breathing:
        return 'breathing';
      case WellnessSessionType.workout:
        return 'workout';
      case WellnessSessionType.stretching:
        return 'stretching';
      case WellnessSessionType.mindfulness:
        return 'mindfulness';
      case WellnessSessionType.relaxation:
        return 'relaxation';
      case WellnessSessionType.yoga:
        return 'yoga';
      case WellnessSessionType.pilates:
        return 'pilates';
      case WellnessSessionType.cardio:
        return 'cardio';
      case WellnessSessionType.strength:
        return 'strength';
      case WellnessSessionType.mobility:
        return 'mobility';
      case WellnessSessionType.recovery:
        return 'recovery';
      case WellnessSessionType.sleep:
        return 'sleep';
      case WellnessSessionType.focus:
        return 'focus';
      case WellnessSessionType.creativity:
        return 'creativity';
      case WellnessSessionType.gratitude:
        return 'gratitude';
    }
  }

  WellnessSessionType _mapBackendSessionType(String type) {
    switch (type.toLowerCase()) {
      case 'meditation':
        return WellnessSessionType.meditation;
      case 'breathing':
        return WellnessSessionType.breathing;
      case 'workout':
        return WellnessSessionType.workout;
      case 'stretching':
        return WellnessSessionType.stretching;
      case 'mindfulness':
        return WellnessSessionType.mindfulness;
      case 'relaxation':
        return WellnessSessionType.relaxation;
      case 'yoga':
        return WellnessSessionType.yoga;
      case 'pilates':
        return WellnessSessionType.pilates;
      case 'cardio':
        return WellnessSessionType.cardio;
      case 'strength':
        return WellnessSessionType.strength;
      case 'mobility':
        return WellnessSessionType.mobility;
      case 'recovery':
        return WellnessSessionType.recovery;
      case 'sleep':
        return WellnessSessionType.sleep;
      case 'focus':
        return WellnessSessionType.focus;
      case 'creativity':
        return WellnessSessionType.creativity;
      case 'gratitude':
        return WellnessSessionType.gratitude;
      default:
        return WellnessSessionType.relaxation;
    }
  }

  String _mapSessionDifficulty(SessionDifficulty difficulty) {
    switch (difficulty) {
      case SessionDifficulty.beginner:
        return 'beginner';
      case SessionDifficulty.intermediate:
        return 'intermediate';
      case SessionDifficulty.advanced:
        return 'advanced';
    }
  }

  SessionDifficulty _mapBackendSessionDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return SessionDifficulty.beginner;
      case 'intermediate':
        return SessionDifficulty.intermediate;
      case 'advanced':
      default:
        return SessionDifficulty.advanced;
    }
  }

  String _mapSessionStatus(SessionStatus status) {
    switch (status) {
      case SessionStatus.notStarted:
        return 'not_started';
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.paused:
        return 'paused';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.skipped:
        return 'skipped';
    }
  }

  SessionStatus _mapBackendSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'not_started':
        return SessionStatus.notStarted;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'paused':
        return SessionStatus.paused;
      case 'completed':
        return SessionStatus.completed;
      case 'skipped':
        return SessionStatus.skipped;
      default:
        return SessionStatus.notStarted;
    }
  }

  // Convert backend response to frontend wellness session
  WellnessSession _dtoToWellnessSession(Map<String, dynamic> data) {
    // Parse instructions and benefits from JSON strings to lists
    List<String> instructions = [];
    List<String> benefits = [];

    if (data['instructions'] is String) {
      try {
        final instructionsData = data['instructions'] as String;
        // Assume instructions are stored as newline-separated or JSON array
        if (instructionsData.startsWith('[')) {
          instructions = List<String>.from(
            (jsonDecode(instructionsData) as List).cast<String>()
          );
        } else {
          instructions = instructionsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
        }
      } catch (e) {
        instructions = [data['instructions'] as String];
      }
    }

    if (data['benefits'] is String) {
      try {
        final benefitsData = data['benefits'] as String;
        if (benefitsData.startsWith('[')) {
          benefits = List<String>.from(
            (jsonDecode(benefitsData) as List).cast<String>()
          );
        } else {
          benefits = benefitsData.split('\n').where((s) => s.trim().isNotEmpty).toList();
        }
      } catch (e) {
        benefits = [data['benefits'] as String];
      }
    }

    return WellnessSession(
      id: data['id'].toString(), // Convert numeric ID to string for frontend
      title: data['title'] as String,
      description: data['description'] as String,
      type: _mapBackendSessionType(data['type'] as String),
      duration: Duration(minutes: data['duration'] as int),
      difficulty: _mapBackendSessionDifficulty(data['difficulty'] as String? ?? 'beginner'),
      audioUrl: data['audioUrl'] as String?,
      videoUrl: data['videoUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
      instructions: instructions,
      benefits: benefits,
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
      isPremium: data['isPremium'] as bool? ?? false,
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  // Convert backend session progress to frontend model
  SessionProgress _dtoToSessionProgress(Map<String, dynamic> data) {
    return SessionProgress(
      id: data['id'].toString(),
      sessionId: data['sessionId'].toString(),
      userId: data['userId'].toString(),
      status: _mapBackendSessionStatus(data['status'] as String? ?? 'not_started'),
      progressTime: Duration(seconds: data['progressTime'] as int? ?? 0),
      startedAt: DateTime.parse(data['startedAt'] as String),
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt'] as String) : null,
      pausedAt: data['pausedAt'] != null ? DateTime.parse(data['pausedAt'] as String) : null,
      rating: data['rating'] as int?,
      feedback: data['feedback'] as String?,
      sessionData: (data['sessionData'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  // Fetch all wellness sessions
  Future<List<WellnessSession>> getSessions({
    WellnessSessionType? type,
    SessionDifficulty? difficulty,
    bool? isPremium,
    List<String>? tags,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = _mapSessionType(type);
      if (difficulty != null) queryParams['difficulty'] = _mapSessionDifficulty(difficulty);
      if (isPremium != null) queryParams['isPremium'] = isPremium.toString();
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.get(
        'wellness/sessions',
        queryParams: queryParams,
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((item) => _dtoToWellnessSession(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wellness sessions: $e');
      }
      rethrow;
    }
  }

  // Get a specific wellness session
  Future<WellnessSession?> getSession(String sessionId) async {
    try {
      // Convert string ID to number for backend
      final numericId = int.tryParse(sessionId);
      if (numericId == null) {
        throw Exception('Invalid session ID format: $sessionId');
      }
      
      final response = await _apiClient.get('wellness/sessions/$numericId');

      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        return _dtoToWellnessSession(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wellness session: $e');
      }
      rethrow;
    }
  }

  // Start a wellness session
  Future<SessionProgress> startSession(String sessionId, {Map<String, dynamic>? sessionData}) async {
    try {
      // Convert string ID to number for backend
      final numericId = int.tryParse(sessionId);
      if (numericId == null) {
        throw Exception('Invalid session ID format: $sessionId');
      }
      
      final body = <String, dynamic>{};
      if (sessionData != null) body['sessionData'] = sessionData;

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('wellness/sessions/$numericId/start', body: body),
      );

      if (response['data'] == null) {
        throw Exception('Session start failed - no data returned');
      }
      return _dtoToSessionProgress(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error starting wellness session: $e');
      }
      rethrow;
    }
  }

  // Update session progress
  Future<SessionProgress> updateSessionProgress(
    String sessionId, {
    SessionStatus? status,
    Duration? progressTime,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      // Convert string ID to number for backend
      final numericId = int.tryParse(sessionId);
      if (numericId == null) {
        throw Exception('Invalid session ID format: $sessionId');
      }
      
      final body = <String, dynamic>{};
      if (status != null) body['status'] = _mapSessionStatus(status);
      if (progressTime != null) body['progressTime'] = progressTime.inSeconds;
      if (sessionData != null) body['sessionData'] = sessionData;

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.patch('wellness/sessions/$numericId/progress', body: body),
      );

      if (response['data'] == null) {
        throw Exception('Session start failed - no data returned');
      }
      return _dtoToSessionProgress(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating session progress: $e');
      }
      rethrow;
    }
  }

  // Complete a wellness session
  Future<SessionProgress> completeSession(
    String sessionId, {
    int? rating,
    String? feedback,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      // Convert string ID to number for backend
      final numericId = int.tryParse(sessionId);
      if (numericId == null) {
        throw Exception('Invalid session ID format: $sessionId');
      }
      
      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (feedback != null) body['feedback'] = feedback;
      if (sessionData != null) body['sessionData'] = sessionData;

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('wellness/sessions/$numericId/complete', body: body),
      );

      if (response['data'] == null) {
        throw Exception('Session start failed - no data returned');
      }
      return _dtoToSessionProgress(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error completing wellness session: $e');
      }
      rethrow;
    }
  }

  // Get user session progress
  Future<List<SessionProgress>> getUserProgress({String? sessionId}) async {
    try {
      final queryParams = <String, String>{};
      if (sessionId != null) {
        // Ensure sessionId is a valid numeric string for backend
        final numericId = int.tryParse(sessionId);
        if (numericId == null) {
          throw Exception('Invalid session ID format: $sessionId');
        }
        queryParams['sessionId'] = numericId.toString();
      }

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('wellness/sessions/user-progress', queryParams: queryParams),
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((item) => _dtoToSessionProgress(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user session progress: $e');
      }
      rethrow;
    }
  }

  // Get wellness statistics
  Future<Map<String, dynamic>> getWellnessStats() async {
    try {
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('wellness/stats'),
      );

      return response['data'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching wellness stats: $e');
      }
      rethrow;
    }
  }

  // Get featured sessions (using tags)
  Future<List<WellnessSession>> getFeaturedSessions({int limit = 5}) async {
    return getSessions(tags: ['featured'], limit: limit);
  }

  // Get quick sessions (sessions under 10 minutes)
  Future<List<WellnessSession>> getQuickSessions({int limit = 5}) async {
    final allSessions = await getSessions();
    return allSessions
        .where((session) => session.duration.inMinutes <= 10)
        .take(limit)
        .toList();
  }

  // Get recent sessions (using tags)
  Future<List<WellnessSession>> getRecentSessions({int limit = 3}) async {
    return getSessions(tags: ['recent'], limit: limit);
  }
}