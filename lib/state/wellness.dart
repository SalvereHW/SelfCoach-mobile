import 'package:flutter/foundation.dart';
import '../models/wellness_session.dart';
import '../services/wellness_api_service.dart';

class WellnessState extends ChangeNotifier {
  final WellnessApiService _apiService = WellnessApiService();
  List<WellnessSession> _sessions = [];
  List<SessionProgress> _sessionProgress = [];
  WellnessSession? _currentSession;
  SessionProgress? _currentProgress;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  List<WellnessSession> get sessions => List.unmodifiable(_sessions);
  List<SessionProgress> get sessionProgress => List.unmodifiable(_sessionProgress);
  WellnessSession? get currentSession => _currentSession;
  SessionProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  // Get sessions by type
  List<WellnessSession> getSessionsByType(WellnessSessionType type) =>
      _sessions.where((session) => session.type == type).toList();

  // Get featured sessions (could be based on user preferences, popularity, etc.)
  List<WellnessSession> get featuredSessions =>
      _sessions.where((session) => session.tags.contains('featured')).take(5).toList();

  // Get recent sessions
  List<WellnessSession> get recentSessions =>
      _sessions.where((session) => session.tags.contains('recent')).take(3).toList();

  // Get quick sessions (under 10 minutes)
  List<WellnessSession> get quickSessions =>
      _sessions.where((session) => session.duration.inMinutes <= 10).toList();

  // Get completed sessions
  List<SessionProgress> get completedSessions =>
      _sessionProgress.where((progress) => progress.isCompleted).toList();

  // Get session statistics
  Map<String, dynamic> getSessionStats() {
    final completed = completedSessions.length;
    final totalTime = completedSessions.fold<Duration>(
      Duration.zero,
      (sum, progress) => sum + progress.progressTime,
    );
    
    final typeStats = <WellnessSessionType, int>{};
    for (final progress in completedSessions) {
      try {
        final session = _sessions.firstWhere((s) => s.id == progress.sessionId);
        typeStats[session.type] = (typeStats[session.type] ?? 0) + 1;
      } catch (e) {
        // Skip if session not found
        if (kDebugMode) {
          print('Session not found for progress: ${progress.sessionId}');
        }
      }
    }

    final ratedSessions = completedSessions.where((p) => p.rating != null);
    final averageRating = ratedSessions.isNotEmpty
        ? ratedSessions.map((p) => p.rating!).reduce((a, b) => a + b) / ratedSessions.length
        : 0.0;

    return {
      'totalSessions': completed,
      'totalTime': totalTime,
      'averageRating': averageRating,
      'typeStats': typeStats,
      'streak': _calculateStreak(),
      'thisWeekSessions': _getThisWeekSessions(),
    };
  }

  int _calculateStreak() {
    final now = DateTime.now();
    var streak = 0;
    var currentDate = DateTime(now.year, now.month, now.day);
    
    while (true) {
      final hasSessionOnDate = completedSessions.any((progress) {
        final completedDate = progress.completedAt;
        if (completedDate == null) return false;
        final date = DateTime(completedDate.year, completedDate.month, completedDate.day);
        return date.isAtSameMomentAs(currentDate);
      });
      
      if (hasSessionOnDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _getThisWeekSessions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return completedSessions.where((progress) {
      final completedDate = progress.completedAt;
      if (completedDate == null) return false;
      return completedDate.isAfter(weekStart) && completedDate.isBefore(weekEnd);
    }).length;
  }

  Future<void> loadSessions() async {
    _setLoading(true);
    _clearError();

    try {
      // Try to load from API first
      if (_apiService.isAuthenticated) {
        final apiSessions = await _apiService.getSessions();
        final apiProgress = await _apiService.getUserProgress();
        _sessions = apiSessions;
        _sessionProgress = apiProgress;
        _isOnline = true;
      } else {
        // Fall back to mock data if not authenticated
        await _loadMockSessions();
        await _loadSessionProgress();
        _isOnline = false;
      }
      notifyListeners();
    } catch (e) {
      // If API fails, fall back to mock data
      if (kDebugMode) {
        print('API call failed, using mock data: $e');
      }
      await _loadMockSessions();
      await _loadSessionProgress();
      _isOnline = false;
      // Don't show error for fallback, just set offline status
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startSession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      _currentSession = session;
      
      SessionProgress progress;
      
      if (_isOnline && _apiService.isAuthenticated) {
        // Start session via API
        final sessionData = {'totalDuration': session.duration.inSeconds};
        progress = await _apiService.startSession(sessionId, sessionData: sessionData);
      } else {
        // Create progress locally for offline mode
        final now = DateTime.now();
        progress = SessionProgress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sessionId: sessionId,
          userId: 'current_user',
          status: SessionStatus.inProgress,
          startedAt: now,
          sessionData: {'totalDuration': session.duration.inSeconds},
          createdAt: now,
          updatedAt: now,
        );
      }
      
      _currentProgress = progress;
      _sessionProgress.add(progress);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSessionProgress(Duration progressTime) async {
    if (_currentProgress == null) return false;

    try {
      SessionProgress updatedProgress;
      
      if (_isOnline && _apiService.isAuthenticated) {
        // Update progress via API
        updatedProgress = await _apiService.updateSessionProgress(
          _currentSession!.id,
          progressTime: progressTime,
        );
      } else {
        // Update locally for offline mode
        updatedProgress = _currentProgress!.copyWith(
          progressTime: progressTime,
          updatedAt: DateTime.now(),
        );
      }
      
      _currentProgress = updatedProgress;
      
      final index = _sessionProgress.indexWhere((p) => p.id == updatedProgress.id);
      if (index != -1) {
        _sessionProgress[index] = updatedProgress;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update session progress: $e');
      return false;
    }
  }

  Future<bool> pauseSession() async {
    if (_currentProgress == null) return false;

    try {
      final updatedProgress = _currentProgress!.copyWith(
        status: SessionStatus.paused,
        pausedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _currentProgress = updatedProgress;
      
      final index = _sessionProgress.indexWhere((p) => p.id == updatedProgress.id);
      if (index != -1) {
        _sessionProgress[index] = updatedProgress;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to pause session: $e');
      return false;
    }
  }

  Future<bool> resumeSession() async {
    if (_currentProgress == null) return false;

    try {
      final updatedProgress = _currentProgress!.copyWith(
        status: SessionStatus.inProgress,
        pausedAt: null,
        updatedAt: DateTime.now(),
      );
      
      _currentProgress = updatedProgress;
      
      final index = _sessionProgress.indexWhere((p) => p.id == updatedProgress.id);
      if (index != -1) {
        _sessionProgress[index] = updatedProgress;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to resume session: $e');
      return false;
    }
  }

  Future<bool> completeSession({int? rating, String? feedback}) async {
    if (_currentProgress == null) return false;

    try {
      SessionProgress updatedProgress;
      
      if (_isOnline && _apiService.isAuthenticated) {
        // Complete session via API
        updatedProgress = await _apiService.completeSession(
          _currentSession!.id,
          rating: rating,
          feedback: feedback,
        );
      } else {
        // Complete locally for offline mode
        updatedProgress = _currentProgress!.copyWith(
          status: SessionStatus.completed,
          completedAt: DateTime.now(),
          rating: rating,
          feedback: feedback,
          updatedAt: DateTime.now(),
        );
      }
      
      final index = _sessionProgress.indexWhere((p) => p.id == updatedProgress.id);
      if (index != -1) {
        _sessionProgress[index] = updatedProgress;
      }
      
      _currentProgress = null;
      _currentSession = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to complete session: $e');
      return false;
    }
  }

  Future<bool> endSession() async {
    _currentSession = null;
    _currentProgress = null;
    notifyListeners();
    return true;
  }

  Future<void> _loadMockSessions() async {
    final now = DateTime.now();
    _sessions = [
      // Meditation Sessions
      WellnessSession(
        id: '1', // Keep as string for frontend compatibility, but ensure it's numeric
        title: 'Morning Mindfulness',
        description: 'Start your day with clarity and intention through this gentle morning meditation.',
        type: WellnessSessionType.meditation,
        duration: const Duration(minutes: 10),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          'Find a comfortable seated position',
          'Close your eyes and focus on your breath',
          'Notice thoughts without judgment',
          'Return attention to your breath when mind wanders',
        ],
        benefits: [
          'Reduced stress and anxiety',
          'Improved focus and clarity',
          'Better emotional regulation',
        ],
        tags: ['featured', 'morning', 'beginner'],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      WellnessSession(
        id: '2', // Keep as string for frontend compatibility, but ensure it's numeric
        title: 'Deep Focus Meditation',
        description: 'Enhance your concentration and mental clarity with this focused meditation practice.',
        type: WellnessSessionType.meditation,
        duration: const Duration(minutes: 20),
        difficulty: SessionDifficulty.intermediate,
        instructions: [
          'Sit with spine straight and eyes closed',
          'Focus on a single point of concentration',
          'Maintain steady, rhythmic breathing',
          'Gently redirect attention when it wanders',
        ],
        benefits: [
          'Enhanced concentration',
          'Mental clarity',
          'Reduced mental chatter',
        ],
        tags: ['focus', 'intermediate'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      
      // Breathing Exercises
      WellnessSession(
        id: '3', // Keep as string for frontend compatibility, but ensure it's numeric
        title: '4-7-8 Breathing',
        description: 'A powerful breathing technique to reduce anxiety and promote relaxation.',
        type: WellnessSessionType.breathing,
        duration: const Duration(minutes: 5),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          'Exhale completely through your mouth',
          'Inhale through nose for 4 counts',
          'Hold breath for 7 counts',
          'Exhale through mouth for 8 counts',
          'Repeat cycle 4 times',
        ],
        benefits: [
          'Reduced anxiety',
          'Better sleep',
          'Stress relief',
        ],
        tags: ['featured', 'quick', 'anxiety'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      WellnessSession(
        id: '4', // Keep as string for frontend compatibility, but ensure it's numeric
        title: 'Box Breathing',
        description: 'Equal-count breathing for balance and focus.',
        type: WellnessSessionType.breathing,
        duration: const Duration(minutes: 8),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          'Inhale for 4 counts',
          'Hold for 4 counts',
          'Exhale for 4 counts',
          'Hold empty for 4 counts',
          'Repeat for full session',
        ],
        benefits: [
          'Improved focus',
          'Stress reduction',
          'Emotional balance',
        ],
        tags: ['focus', 'balance'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      
      // Quick Workouts
      WellnessSession(
        id: '5', // Keep as string for frontend compatibility, but ensure it's numeric
        title: '5-Minute Energy Boost',
        description: 'Quick exercises to energize your body and mind.',
        type: WellnessSessionType.workout,
        duration: const Duration(minutes: 5),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          '1 minute jumping jacks',
          '1 minute bodyweight squats',
          '1 minute push-ups (modified if needed)',
          '1 minute mountain climbers',
          '1 minute stretching',
        ],
        benefits: [
          'Increased energy',
          'Improved circulation',
          'Mental alertness',
        ],
        tags: ['featured', 'recent', 'energy', 'quick'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      
      // Stretching
      WellnessSession(
        id: '6', // Keep as string for frontend compatibility, but ensure it's numeric
        title: 'Desk Break Stretches',
        description: 'Relief for neck, shoulders, and back from prolonged sitting.',
        type: WellnessSessionType.stretching,
        duration: const Duration(minutes: 7),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          'Neck rolls and shoulder shrugs',
          'Seated spinal twist',
          'Shoulder blade squeezes',
          'Seated forward fold',
          'Hip flexor stretch',
        ],
        benefits: [
          'Reduced muscle tension',
          'Improved posture',
          'Increased flexibility',
        ],
        tags: ['recent', 'office', 'quick'],
        createdAt: now,
        updatedAt: now,
      ),
      
      // Relaxation
      WellnessSession(
        id: '7', // Keep as string for frontend compatibility, but ensure it's numeric
        title: 'Progressive Muscle Relaxation',
        description: 'Systematic tension and release of muscle groups for deep relaxation.',
        type: WellnessSessionType.relaxation,
        duration: const Duration(minutes: 15),
        difficulty: SessionDifficulty.beginner,
        instructions: [
          'Lie down comfortably',
          'Tense each muscle group for 5 seconds',
          'Release and notice the relaxation',
          'Progress from toes to head',
          'End with full-body relaxation',
        ],
        benefits: [
          'Deep relaxation',
          'Stress relief',
          'Better sleep quality',
        ],
        tags: ['recent', 'sleep', 'relaxation'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _loadSessionProgress() async {
    // Initialize with empty progress - no dummy data
    _sessionProgress = [];
  }

  // Clear all session progress (useful for testing or reset)
  void clearSessionProgress() {
    _sessionProgress.clear();
    _currentProgress = null;
    notifyListeners();
    if (kDebugMode) {
      print('Session progress cleared');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}