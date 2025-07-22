import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/ai_insight.dart';
import '../services/ai_insights_api_service.dart';
import '../services/api_client.dart';

class AiInsightsState extends ChangeNotifier {
  AiInsightsApiService? _apiService;
  
  final List<AiInsight> _insights = [];
  final List<AiInsight> _unreadInsights = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;
  GenerationLimitCheck? _generationLimitCheck;

  // Getters
  List<AiInsight> get insights => List.unmodifiable(_insights);
  List<AiInsight> get unreadInsights => List.unmodifiable(_unreadInsights);
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  GenerationLimitCheck? get generationLimitCheck => _generationLimitCheck;
  bool get isAuthenticated => _apiService != null;

  // Convenience getters
  List<AiInsight> get dailySummaries => 
      _insights.where((insight) => insight.type == InsightType.dailySummary).toList();
  
  List<AiInsight> get recommendations => 
      _insights.where((insight) => insight.type == InsightType.recommendation).toList();
  
  List<AiInsight> get healthTrends => 
      _insights.where((insight) => insight.type == InsightType.healthTrend).toList();

  int get unreadCount => _unreadInsights.length;

  bool get canGenerateInsight => 
      _generationLimitCheck?.canGenerate ?? false;

  int get remainingGenerations => 
      _generationLimitCheck?.remainingGenerations ?? 0;

  void initializeApiService(BuildContext context) {
    _apiService = AiInsightsApiService(ApiClient(context: context));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      if (kDebugMode) {
        print('AiInsightsState Error: $error');
      }
    }
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> loadInsights({int limit = 50}) async {
    if (_apiService == null) {
      _setError('API service not initialized. Call initializeApiService() first.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        print('AiInsightsState: Loading insights...');
      }

      final insights = await _apiService!.getInsights(limit: limit);
      
      if (kDebugMode) {
        print('AiInsightsState: Loaded ${insights.length} insights');
      }

      _insights.clear();
      _insights.addAll(insights);
      
      // Sort insights by creation date (newest first)
      _insights.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error loading insights: $e');
      }
      _setError('Failed to load insights: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUnreadInsights() async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return;
    }

    try {
      final unreadInsights = await _apiService!.getUnreadInsights();
      
      _unreadInsights.clear();
      _unreadInsights.addAll(unreadInsights);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error loading unread insights: $e');
      }
      _setError('Failed to load unread insights: $e');
    }
  }

  Future<void> checkGenerationLimit() async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return;
    }

    try {
      _generationLimitCheck = await _apiService!.checkGenerationLimit();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error checking generation limit: $e');
      }
      // Set a default limit check on error - assume user can generate
      _generationLimitCheck = const GenerationLimitCheck(
        canGenerate: true,
        remainingGenerations: 3,
      );
      // Don't set error for generation limit check failures to avoid blocking the UI
    }
  }

  Future<bool> generateInsight({
    InsightType? type,
    DateTime? date,
    bool includeRecommendations = true,
  }) async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return false;
    }

    _setGenerating(true);
    _clearError();

    try {
      if (kDebugMode) {
        print('AiInsightsState: Generating insight...');
      }

      final insight = await _apiService!.generateInsight(
        type: type,
        date: date,
        includeRecommendations: includeRecommendations,
      );

      if (kDebugMode) {
        print('AiInsightsState: Generated insight with ID: ${insight.id}');
      }

      // Add to the beginning of the list (newest first)
      _insights.insert(0, insight);
      
      // If it's unread, add to unread list
      if (!insight.isRead) {
        _unreadInsights.insert(0, insight);
      }

      // Update generation limit check
      await checkGenerationLimit();

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error generating insight: $e');
      }
      _setError('Failed to generate insight: $e');
      return false;
    } finally {
      _setGenerating(false);
    }
  }

  Future<bool> markAsRead(String insightId) async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return false;
    }

    try {
      final updatedInsight = await _apiService!.markAsRead(insightId);
      
      // Update in insights list
      final index = _insights.indexWhere((insight) => insight.id == insightId);
      if (index != -1) {
        _insights[index] = updatedInsight;
      }
      
      // Remove from unread list
      _unreadInsights.removeWhere((insight) => insight.id == insightId);
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error marking insight as read: $e');
      }
      _setError('Failed to mark insight as read: $e');
      return false;
    }
  }

  Future<bool> markAsDismissed(String insightId) async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return false;
    }

    try {
      final updatedInsight = await _apiService!.markAsDismissed(insightId);
      
      // Update in insights list
      final index = _insights.indexWhere((insight) => insight.id == insightId);
      if (index != -1) {
        _insights[index] = updatedInsight;
      }
      
      // Remove from unread list
      _unreadInsights.removeWhere((insight) => insight.id == insightId);
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error dismissing insight: $e');
      }
      _setError('Failed to dismiss insight: $e');
      return false;
    }
  }

  Future<bool> deleteInsight(String insightId) async {
    if (_apiService == null) {
      _setError('API service not initialized');
      return false;
    }

    try {
      await _apiService!.deleteInsight(insightId);
      
      // Remove from both lists
      _insights.removeWhere((insight) => insight.id == insightId);
      _unreadInsights.removeWhere((insight) => insight.id == insightId);
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AiInsightsState: Error deleting insight: $e');
      }
      _setError('Failed to delete insight: $e');
      return false;
    }
  }

  List<AiInsight> getInsightsByType(InsightType type) {
    return _insights.where((insight) => insight.type == type).toList();
  }

  List<AiInsight> getInsightsByPriority(InsightPriority priority) {
    return _insights.where((insight) => insight.priority == priority).toList();
  }

  List<AiInsight> getRecentInsights({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _insights
        .where((insight) => insight.createdAt.isAfter(cutoffDate))
        .toList();
  }

  List<AiInsight> getActionableInsights() {
    return _insights.where((insight) => insight.isActionable).toList();
  }

  // Helper method to refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadInsights(),
      loadUnreadInsights(),
      checkGenerationLimit(),
    ]);
  }

  @override
  void dispose() {
    _insights.clear();
    _unreadInsights.clear();
    super.dispose();
  }
}