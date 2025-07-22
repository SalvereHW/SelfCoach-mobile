import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/wellness_session.dart';

class LocalStorageService {
  static const String _wellnessSessionsKey = 'wellness_sessions';
  static const String _sessionProgressKey = 'session_progress';
  static const String _stepsDataKey = 'steps_data';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Wellness Sessions Storage
  static Future<void> saveWellnessSessions(List<WellnessSession> sessions) async {
    try {
      final jsonList = sessions.map((session) => session.toJson()).toList();
      await _preferences.setString(_wellnessSessionsKey, jsonEncode(jsonList));
      if (kDebugMode) {
        print('Saved ${sessions.length} wellness sessions to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving wellness sessions: $e');
      }
    }
  }

  static Future<List<WellnessSession>> getWellnessSessions() async {
    try {
      final jsonString = _preferences.getString(_wellnessSessionsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WellnessSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading wellness sessions: $e');
      }
      return [];
    }
  }

  // Session Progress Storage
  static Future<void> saveSessionProgress(List<SessionProgress> progressList) async {
    try {
      final jsonList = progressList.map((progress) => progress.toJson()).toList();
      await _preferences.setString(_sessionProgressKey, jsonEncode(jsonList));
      if (kDebugMode) {
        print('Saved ${progressList.length} session progress records to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session progress: $e');
      }
    }
  }

  static Future<List<SessionProgress>> getSessionProgress() async {
    try {
      final jsonString = _preferences.getString(_sessionProgressKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => SessionProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading session progress: $e');
      }
      return [];
    }
  }

  // Steps Data Storage
  static Future<void> saveStepsData(Map<String, dynamic> stepsData) async {
    try {
      await _preferences.setString(_stepsDataKey, jsonEncode(stepsData));
      if (kDebugMode) {
        print('Saved steps data to local storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving steps data: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> getStepsData() async {
    try {
      final jsonString = _preferences.getString(_stepsDataKey);
      if (jsonString == null) return {};

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading steps data: $e');
      }
      return {};
    }
  }

  // Utility Methods
  static Future<void> clearAllData() async {
    await _preferences.remove(_wellnessSessionsKey);
    await _preferences.remove(_sessionProgressKey);
    await _preferences.remove(_stepsDataKey);
    if (kDebugMode) {
      print('Cleared all local storage data');
    }
  }

  // Session-specific methods
  static Future<void> saveSessionProgressItem(SessionProgress progress) async {
    final existingProgress = await getSessionProgress();
    final index = existingProgress.indexWhere((p) => p.id == progress.id);
    
    if (index != -1) {
      existingProgress[index] = progress;
    } else {
      existingProgress.add(progress);
    }
    
    await saveSessionProgress(existingProgress);
  }

  static Future<SessionProgress?> getSessionProgressById(String id) async {
    final progressList = await getSessionProgress();
    try {
      return progressList.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Steps-specific methods
  static Future<void> saveDailySteps(String date, int steps) async {
    final stepsData = await getStepsData();
    stepsData[date] = steps;
    await saveStepsData(stepsData);
  }

  static Future<int> getDailySteps(String date) async {
    final stepsData = await getStepsData();
    return stepsData[date] as int? ?? 0;
  }

  static Future<Map<String, int>> getWeeklySteps() async {
    final stepsData = await getStepsData();
    final now = DateTime.now();
    final weeklySteps = <String, int>{};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      weeklySteps[dateKey] = stepsData[dateKey] as int? ?? 0;
    }
    
    return weeklySteps;
  }
}