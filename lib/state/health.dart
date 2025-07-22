import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/health_metrics.dart';
import '../services/health_api_service.dart';

class HealthState extends ChangeNotifier {
  HealthApiService? _apiService;
  final List<SleepMetrics> _sleepData = [];
  final List<NutritionMetrics> _nutritionData = [];
  final List<ActivityMetrics> _activityData = [];
  final List<DailyHealthSummary> _dailySummaries = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  // Initialize API service with context
  void initializeApiService(BuildContext context) {
    if (_apiService == null) {
      _apiService = HealthApiService(context: context);
    } else {
      // Update context if service already exists
      _apiService!.updateContext(context);
    }
  }

  // Getters
  List<SleepMetrics> get sleepData => List.unmodifiable(_sleepData);
  List<NutritionMetrics> get nutritionData => List.unmodifiable(_nutritionData);
  List<ActivityMetrics> get activityData => List.unmodifiable(_activityData);
  List<DailyHealthSummary> get dailySummaries => List.unmodifiable(_dailySummaries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  // Computed properties
  SleepMetrics? get todaysSleep {
    final today = DateTime.now();
    if (kDebugMode) {
      print('HealthState: todaysSleep getter called');
      print('HealthState: Today is: $today');
      print('HealthState: Total sleep records: ${_sleepData.length}');
      for (final sleep in _sleepData) {
        print('HealthState: Sleep record date: ${sleep.date}, same day: ${_isSameDay(sleep.date, today)}');
      }
    }
    
    return _sleepData
        .where((sleep) => _isSameDay(sleep.date, today))
        .firstOrNull;
  }

  // Get most recent sleep data (for dashboard display)
  SleepMetrics? get mostRecentSleep {
    if (_sleepData.isEmpty) return null;
    return _sleepData.first; // Data is sorted by date (newest first)
  }

  // Get most recent nutrition data (for dashboard display)
  List<NutritionMetrics> get mostRecentNutrition {
    if (_nutritionData.isEmpty) return [];
    final mostRecentDate = _nutritionData.first.date;
    return _nutritionData
        .where((nutrition) => _isSameDay(nutrition.date, mostRecentDate))
        .toList();
  }

  // Get most recent activity data (for dashboard display)
  List<ActivityMetrics> get mostRecentActivities {
    if (_activityData.isEmpty) return [];
    final mostRecentDate = _activityData.first.date;
    return _activityData
        .where((activity) => _isSameDay(activity.date, mostRecentDate))
        .toList();
  }

  DailyHealthSummary? get todaysSummary => _dailySummaries
      .where((summary) => _isSameDay(summary.date, DateTime.now()))
      .firstOrNull;

  List<NutritionMetrics> get todaysNutrition => _nutritionData
      .where((nutrition) => _isSameDay(nutrition.date, DateTime.now()))
      .toList();

  List<ActivityMetrics> get todaysActivities => _activityData
      .where((activity) => _isSameDay(activity.date, DateTime.now()))
      .toList();

  int get todaysTotalCalories => todaysNutrition
      .where((nutrition) => nutrition.calories != null)
      .fold(0, (sum, nutrition) => sum + nutrition.calories!);

  int get todaysBurnedCalories => todaysActivities
      .where((activity) => activity.caloriesBurned != null)
      .fold(0, (sum, activity) => sum + activity.caloriesBurned!);

  int get todaysTotalSteps => todaysActivities
      .where((activity) => activity.steps != null)
      .fold(0, (sum, activity) => sum + activity.steps!);

  // Most recent data for dashboard
  int get mostRecentTotalCalories => mostRecentNutrition
      .where((nutrition) => nutrition.calories != null)
      .fold(0, (sum, nutrition) => sum + nutrition.calories!);

  int get mostRecentBurnedCalories => mostRecentActivities
      .where((activity) => activity.caloriesBurned != null)
      .fold(0, (sum, activity) => sum + activity.caloriesBurned!);

  int get mostRecentTotalSteps => mostRecentActivities
      .where((activity) => activity.steps != null)
      .fold(0, (sum, activity) => sum + activity.steps!);

  // Average heart rate from recent activities
  int get mostRecentAverageHeartRate {
    final activitiesWithHeartRate = mostRecentActivities
        .where((activity) => activity.averageHeartRate != null);
    
    if (activitiesWithHeartRate.isEmpty) return 0;
    
    final totalHeartRate = activitiesWithHeartRate
        .fold(0, (sum, activity) => sum + activity.averageHeartRate!);
    
    return (totalHeartRate / activitiesWithHeartRate.length).round();
  }

  double get weeklyAverageSleep {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final weekSleepData = _sleepData
        .where((sleep) => sleep.date.isAfter(lastWeek) && sleep.duration != null)
        .toList();
    
    if (weekSleepData.isEmpty) return 0.0;
    
    final totalMinutes = weekSleepData
        .fold(0, (sum, sleep) => sum + sleep.duration!.inMinutes);
    
    return totalMinutes / weekSleepData.length / 60; // hours
  }

  // Date management
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<SleepMetrics> getSleepDataForDate(DateTime date) {
    return _sleepData.where((sleep) => _isSameDay(sleep.date, date)).toList();
  }

  List<NutritionMetrics> getNutritionDataForDate(DateTime date) {
    return _nutritionData.where((nutrition) => _isSameDay(nutrition.date, date)).toList();
  }

  List<ActivityMetrics> getActivityDataForDate(DateTime date) {
    return _activityData.where((activity) => _isSameDay(activity.date, date)).toList();
  }

  DailyHealthSummary? getDailySummaryForDate(DateTime date) {
    return _dailySummaries
        .where((summary) => _isSameDay(summary.date, date))
        .firstOrNull;
  }

  // Sleep data management
  Future<bool> addSleepData(SleepMetrics sleepMetrics) async {
    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        print('HealthState: Adding sleep data for date ${sleepMetrics.date}');
        print('HealthState: API service authenticated: ${_apiService?.isAuthenticated ?? false}');
      }
      
      if (_apiService == null) {
        throw Exception('API service not initialized. Call initializeApiService() first.');
      }
      
      // Create sleep data via API
      final createdSleep = await _apiService!.createSleep(sleepMetrics);
      
      if (kDebugMode) {
        print('HealthState: Sleep data created successfully with ID: ${createdSleep.id}');
      }
      
      // Remove existing sleep data for the same date
      _sleepData.removeWhere((sleep) => _isSameDay(sleep.date, createdSleep.date));
      
      // Add new sleep data
      _sleepData.add(createdSleep);
      _sleepData.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('HealthState: Error adding sleep data: $e');
      }
      _setError('Failed to add sleep data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSleepData(SleepMetrics updatedSleep) async {
    _setLoading(true);
    _clearError();

    try {
      // Update sleep data via API
      final updated = await _apiService!.updateSleep(updatedSleep.id, updatedSleep);
      
      final index = _sleepData.indexWhere((sleep) => sleep.id == updatedSleep.id);
      if (index != -1) {
        _sleepData[index] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update sleep data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSleepData(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete sleep data via API
      await _apiService!.deleteSleep(id);
      
      _sleepData.removeWhere((sleep) => sleep.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete sleep data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Nutrition data management
  Future<bool> addNutritionData(NutritionMetrics nutritionMetrics) async {
    _setLoading(true);
    _clearError();

    try {
      // Create nutrition data via API
      final createdNutrition = await _apiService!.createNutrition(nutritionMetrics);
      
      _nutritionData.add(createdNutrition);
      _nutritionData.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add nutrition data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNutritionData(NutritionMetrics updatedNutrition) async {
    _setLoading(true);
    _clearError();

    try {
      // Update nutrition data via API
      final updated = await _apiService!.updateNutrition(updatedNutrition.id, updatedNutrition);
      
      final index = _nutritionData.indexWhere((nutrition) => nutrition.id == updatedNutrition.id);
      if (index != -1) {
        _nutritionData[index] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update nutrition data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNutritionData(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete nutrition data via API
      await _apiService!.deleteNutrition(id);
      
      _nutritionData.removeWhere((nutrition) => nutrition.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete nutrition data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Activity data management
  Future<bool> addActivityData(ActivityMetrics activityMetrics) async {
    _setLoading(true);
    _clearError();

    try {
      // Create activity data via API
      final createdActivity = await _apiService!.createActivity(activityMetrics);
      
      _activityData.add(createdActivity);
      _activityData.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add activity data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateActivityData(ActivityMetrics updatedActivity) async {
    _setLoading(true);
    _clearError();

    try {
      // Update activity data via API
      final updated = await _apiService!.updateActivity(updatedActivity.id, updatedActivity);
      
      final index = _activityData.indexWhere((activity) => activity.id == updatedActivity.id);
      if (index != -1) {
        _activityData[index] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update activity data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteActivityData(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete activity data via API
      await _apiService!.deleteActivity(id);
      
      _activityData.removeWhere((activity) => activity.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete activity data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Daily summary management
  Future<bool> addOrUpdateDailySummary(DailyHealthSummary summary) async {
    _setLoading(true);
    _clearError();

    try {
      // Remove existing summary for the same date
      _dailySummaries.removeWhere((existing) => _isSameDay(existing.date, summary.date));
      
      // Add new summary
      _dailySummaries.add(summary);
      _dailySummaries.sort((a, b) => b.date.compareTo(a.date));
      
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save daily summary: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Data loading
  Future<void> loadHealthData() async {
    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        print('HealthState: Loading health data...');
        print('HealthState: API service initialized: ${_apiService != null}');
        print('HealthState: API service authenticated: ${_apiService?.isAuthenticated ?? false}');
      }

      // Load data from backend API
      if (_apiService?.isAuthenticated == true) {
        if (kDebugMode) {
          print('HealthState: Fetching data from backend...');
        }
        
        final sleepData = await _apiService!.getSleep();
        final nutritionData = await _apiService!.getNutrition();
        final activityData = await _apiService!.getActivities();
        
        if (kDebugMode) {
          print('HealthState: Fetched ${sleepData.length} sleep records');
          print('HealthState: Fetched ${nutritionData.length} nutrition records');
          print('HealthState: Fetched ${activityData.length} activity records');
          
          // Debug sleep data details
          for (int i = 0; i < sleepData.length; i++) {
            final sleep = sleepData[i];
            print('HealthState: Sleep record $i: date=${sleep.date}, duration=${sleep.duration}, quality=${sleep.quality}');
          }
        }
        
        _sleepData.clear();
        _nutritionData.clear();
        _activityData.clear();
        
        _sleepData.addAll(sleepData);
        _nutritionData.addAll(nutritionData);
        _activityData.addAll(activityData);
        
        // Sort data by date (newest first)
        _sleepData.sort((a, b) => b.date.compareTo(a.date));
        _nutritionData.sort((a, b) => b.date.compareTo(a.date));
        _activityData.sort((a, b) => b.date.compareTo(a.date));
      } else {
        if (kDebugMode) {
          print('HealthState: Skipping data load - not authenticated or API service not initialized');
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('HealthState: Error loading health data: $e');
      }
      _setError('Failed to load health data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
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
    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Clear all data (useful for logout)
  void clearAllData() {
    _sleepData.clear();
    _nutritionData.clear();
    _activityData.clear();
    _dailySummaries.clear();
    _selectedDate = DateTime.now();
    _clearError();
    notifyListeners();
  }
}

// Extension to add firstOrNull for older Dart versions
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}