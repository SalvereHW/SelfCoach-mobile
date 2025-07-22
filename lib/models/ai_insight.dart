import 'package:flutter/foundation.dart';

enum InsightType {
  dailySummary,
  weeklySummary,
  healthTrend,
  recommendation,
  anomalyDetection,
  goalProgress,
}

enum InsightPriority {
  low,
  medium,
  high,
  urgent,
}

class AiInsight {
  final String id;
  final InsightType type;
  final String title;
  final String content;
  final InsightPriority priority;
  final Map<String, dynamic>? metadata;
  final List<String> recommendations;
  final double? confidenceScore;
  final DateTime insightDate;
  final bool isRead;
  final bool isDismissed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.priority,
    this.metadata,
    required this.recommendations,
    this.confidenceScore,
    required this.insightDate,
    required this.isRead,
    required this.isDismissed,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isNew {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return createdAt.isAfter(twoDaysAgo);
  }

  bool get isActionable {
    return recommendations.isNotEmpty;
  }

  String get categoryColor {
    switch (type) {
      case InsightType.dailySummary:
        return '#4F46E5';
      case InsightType.weeklySummary:
        return '#7C3AED';
      case InsightType.healthTrend:
        return '#059669';
      case InsightType.recommendation:
        return '#DC2626';
      case InsightType.anomalyDetection:
        return '#EA580C';
      case InsightType.goalProgress:
        return '#0284C7';
    }
  }

  String get priorityColor {
    switch (priority) {
      case InsightPriority.low:
        return '#10B981';
      case InsightPriority.medium:
        return '#F59E0B';
      case InsightPriority.high:
        return '#EF4444';
      case InsightPriority.urgent:
        return '#DC2626';
    }
  }

  String get typeLabel {
    switch (type) {
      case InsightType.dailySummary:
        return 'Daily Summary';
      case InsightType.weeklySummary:
        return 'Weekly Summary';
      case InsightType.healthTrend:
        return 'Health Trend';
      case InsightType.recommendation:
        return 'Recommendation';
      case InsightType.anomalyDetection:
        return 'Anomaly Detection';
      case InsightType.goalProgress:
        return 'Goal Progress';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case InsightPriority.low:
        return 'Low';
      case InsightPriority.medium:
        return 'Medium';
      case InsightPriority.high:
        return 'High';
      case InsightPriority.urgent:
        return 'Urgent';
    }
  }

  AiInsight copyWith({
    String? id,
    InsightType? type,
    String? title,
    String? content,
    InsightPriority? priority,
    Map<String, dynamic>? metadata,
    List<String>? recommendations,
    double? confidenceScore,
    DateTime? insightDate,
    bool? isRead,
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
      recommendations: recommendations ?? this.recommendations,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      insightDate: insightDate ?? this.insightDate,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _insightTypeToString(type),
      'title': title,
      'content': content,
      'priority': _priorityToString(priority),
      'metadata': metadata,
      'recommendations': recommendations,
      'confidenceScore': confidenceScore,
      'insightDate': insightDate.toIso8601String(),
      'isRead': isRead,
      'isDismissed': isDismissed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    try {
      return AiInsight(
        id: json['id']?.toString() ?? '',
        type: _stringToInsightType(json['type']?.toString() ?? 'daily_summary'),
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        priority: _stringToPriority(json['priority']?.toString() ?? 'medium'),
        metadata: json['metadata'] as Map<String, dynamic>?,
        recommendations: (json['recommendations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        confidenceScore: json['confidenceScore'] != null
            ? double.tryParse(json['confidenceScore'].toString())
            : null,
        insightDate: DateTime.parse(json['insightDate']?.toString() ?? DateTime.now().toIso8601String()),
        isRead: json['isRead'] == true || json['isRead'] == 1,
        isDismissed: json['isDismissed'] == true || json['isDismissed'] == 1,
        createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing AiInsight from JSON: $e');
        print('JSON data: $json');
      }
      rethrow;
    }
  }

  static String _insightTypeToString(InsightType type) {
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

  static InsightType _stringToInsightType(String type) {
    switch (type.toLowerCase()) {
      case 'daily_summary':
        return InsightType.dailySummary;
      case 'weekly_summary':
        return InsightType.weeklySummary;
      case 'health_trend':
        return InsightType.healthTrend;
      case 'recommendation':
        return InsightType.recommendation;
      case 'anomaly_detection':
        return InsightType.anomalyDetection;
      case 'goal_progress':
        return InsightType.goalProgress;
      default:
        return InsightType.dailySummary;
    }
  }

  static String _priorityToString(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return 'low';
      case InsightPriority.medium:
        return 'medium';
      case InsightPriority.high:
        return 'high';
      case InsightPriority.urgent:
        return 'urgent';
    }
  }

  static InsightPriority _stringToPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return InsightPriority.low;
      case 'medium':
        return InsightPriority.medium;
      case 'high':
        return InsightPriority.high;
      case 'urgent':
        return InsightPriority.urgent;
      default:
        return InsightPriority.medium;
    }
  }
}

class GenerationLimitCheck {
  final bool canGenerate;
  final DateTime? nextAvailableTime;
  final int remainingGenerations;

  const GenerationLimitCheck({
    required this.canGenerate,
    this.nextAvailableTime,
    required this.remainingGenerations,
  });

  factory GenerationLimitCheck.fromJson(Map<String, dynamic> json) {
    return GenerationLimitCheck(
      canGenerate: json['canGenerate'] == true,
      nextAvailableTime: json['nextAvailableTime'] != null
          ? DateTime.parse(json['nextAvailableTime'])
          : null,
      remainingGenerations: json['remainingGenerations']?.toInt() ?? 0,
    );
  }
}