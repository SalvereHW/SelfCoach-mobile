import 'package:flutter/foundation.dart';
import '../models/ai_insight.dart';
import 'api_client.dart';

class AiInsightsApiService {
  final ApiClient _apiClient;

  AiInsightsApiService(this._apiClient);

  Future<List<AiInsight>> getInsights({int limit = 50}) async {
    try {
      final response = await _apiClient.get('/ai-insights?limit=$limit');
      if (kDebugMode) {
        print(response);
      }
      if (response['statusCode'] == 200) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => AiInsight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch AI insights: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching AI insights: $e');
      }
      rethrow;
    }
  }

  Future<List<AiInsight>> getUnreadInsights() async {
    try {
      final response = await _apiClient.get('/ai-insights/unread');
      
      if (response['statusCode'] == 200) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => AiInsight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch unread insights: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching unread insights: $e');
      }
      rethrow;
    }
  }

  Future<List<AiInsight>> getInsightsByType(InsightType type, {int limit = 20}) async {
    try {
      final typeString = _insightTypeToString(type);
      final response = await _apiClient.get('/ai-insights/type/$typeString?limit=$limit');
      
      if (response['statusCode'] == 200) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => AiInsight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch insights by type: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching insights by type: $e');
      }
      rethrow;
    }
  }

  Future<AiInsight> generateInsight({
    InsightType? type,
    DateTime? date,
    bool includeRecommendations = true,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (type != null) {
        data['type'] = _insightTypeToString(type);
      }
      
      if (date != null) {
        data['date'] = date.toIso8601String();
      }
      
      data['includeRecommendations'] = includeRecommendations;

      final response = await _apiClient.post('/ai-insights/generate', body: data);
      
      if (kDebugMode) {
        print('Generate insight response: $response');
      }
      
      if (response['statusCode'] == 201) {
        // Handle case where the response data might be the insight object directly
        final insightData = response['data'] ?? response;
        
        if (insightData == null) {
          throw Exception('No insight data received from server');
        }
        
        // Remove statusCode and statusMessage if they exist in the insight data
        if (insightData is Map<String, dynamic>) {
          final cleanedData = Map<String, dynamic>.from(insightData);
          cleanedData.remove('statusCode');
          cleanedData.remove('statusMessage');
          cleanedData.remove('success');
          
          return AiInsight.fromJson(cleanedData);
        }
        
        return AiInsight.fromJson(insightData);
      } else {
        throw Exception('Failed to generate insight: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating insight: $e');
      }
      rethrow;
    }
  }

  Future<GenerationLimitCheck> checkGenerationLimit() async {
    try {
      final response = await _apiClient.get('/ai-insights/generation-status');
      
      if (kDebugMode) {
        print('Generation limit response: $response');
      }
      
      if (response['statusCode'] == 200) {
        final data = response['data'] ?? response;
        
        if (data == null) {
          throw Exception('No generation limit data received from server');
        }
        
        // Handle case where the response data might be the limit check object directly
        if (data is Map<String, dynamic>) {
          final cleanedData = Map<String, dynamic>.from(data);
          cleanedData.remove('statusCode');
          cleanedData.remove('statusMessage');
          cleanedData.remove('success');
          
          return GenerationLimitCheck.fromJson(cleanedData);
        }
        
        return GenerationLimitCheck.fromJson(data);
      } else {
        throw Exception('Failed to check generation limit: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking generation limit: $e');
      }
      rethrow;
    }
  }

  Future<AiInsight> getInsight(String id) async {
    try {
      final response = await _apiClient.get('/ai-insights/$id');
      
      if (response['statusCode'] == 200) {
        return AiInsight.fromJson(response['data']);
      } else {
        throw Exception('Failed to fetch insight: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching insight: $e');
      }
      rethrow;
    }
  }

  Future<AiInsight> markAsRead(String id) async {
    try {
      final response = await _apiClient.patch('/ai-insights/$id/read');
      
      if (response['statusCode'] == 200) {
        return AiInsight.fromJson(response['data']);
      } else {
        throw Exception('Failed to mark insight as read: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking insight as read: $e');
      }
      rethrow;
    }
  }

  Future<AiInsight> markAsDismissed(String id) async {
    try {
      final response = await _apiClient.patch('/ai-insights/$id/dismiss');
      
      if (response['statusCode'] == 200) {
        return AiInsight.fromJson(response['data']);
      } else {
        throw Exception('Failed to dismiss insight: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error dismissing insight: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteInsight(String id) async {
    try {
      final response = await _apiClient.delete('/ai-insights/$id');
      
      if (response['statusCode'] != 204) {
        throw Exception('Failed to delete insight: ${response['statusMessage']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting insight: $e');
      }
      rethrow;
    }
  }

  String _insightTypeToString(InsightType type) {
    switch (type) {
      case InsightType.dailySummary:
        return 'daily_summary';
      case InsightType.weeklySummary:
        return 'weekly_summary';
      case InsightType.healthTrend:
        return 'health_trend';
      case InsightType.recommendation:
        return 'recommendation';
      case InsightType.anomalyDetection:
        return 'anomaly_detection';
      case InsightType.goalProgress:
        return 'goal_progress';
    }
  }
}