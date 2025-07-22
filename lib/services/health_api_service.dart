import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/health_metrics.dart';
import 'api_client.dart';

class HealthApiService {
  ApiClient _apiClient;
  BuildContext? _context;

  HealthApiService({BuildContext? context}) : _apiClient = ApiClient(context: context), _context = context;

  bool get isAuthenticated {
    // If we have a context, make sure the API client uses it
    if (_context != null && _context!.mounted) {
      // Recreate API client with current context if needed
      if (!_apiClient.isAuthenticated) {
        _apiClient = ApiClient(context: _context);
      }
    }
    return _apiClient.isAuthenticated;
  }

  // Method to update context when needed
  void updateContext(BuildContext? context) {
    _context = context;
    if (context != null) {
      _apiClient = ApiClient(context: context);
    }
  }

  // Map frontend activity type to backend
  String _mapActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.running:
        return 'running';
      case ActivityType.walking:
        return 'walking';
      case ActivityType.cycling:
        return 'cycling';
      case ActivityType.swimming:
        return 'swimming';
      case ActivityType.weightLifting:
        return 'strength'; // Map to backend STRENGTH enum
      case ActivityType.yoga:
        return 'yoga';
      case ActivityType.workout:
        return 'cardio'; // Map to backend CARDIO enum
      case ActivityType.pilates:
        return 'pilates';
      case ActivityType.sports:
        return 'sports';
      case ActivityType.other:
        return 'other';
    }
  }

  ActivityType _mapBackendActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return ActivityType.running;
      case 'walking':
        return ActivityType.walking;
      case 'cycling':
        return ActivityType.cycling;
      case 'swimming':
        return ActivityType.swimming;
      case 'strength':
        return ActivityType.weightLifting; // Map from backend STRENGTH enum
      case 'yoga':
        return ActivityType.yoga;
      case 'cardio':
        return ActivityType.workout; // Map from backend CARDIO enum
      case 'pilates':
        return ActivityType.pilates;
      case 'sports':
        return ActivityType.sports;
      case 'other':
      default:
        return ActivityType.other;
    }
  }

  String _mapMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
      case MealType.snack:
        return 'snack';
    }
  }

  MealType _mapBackendMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
      default:
        return MealType.snack;
    }
  }

  String _mapSleepQuality(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return 'poor';
      case SleepQuality.fair:
        return 'fair';
      case SleepQuality.good:
        return 'good';
      case SleepQuality.excellent:
        return 'excellent';
    }
  }

  SleepQuality _mapBackendSleepQuality(String quality) {
    switch (quality.toLowerCase()) {
      case 'poor':
        return SleepQuality.poor;
      case 'fair':
        return SleepQuality.fair;
      case 'good':
        return SleepQuality.good;
      case 'excellent':
      default:
        return SleepQuality.excellent;
    }
  }

  String _mapActivityIntensity(ActivityIntensity intensity) {
    switch (intensity) {
      case ActivityIntensity.light:
        return 'low'; // Map to backend LOW enum
      case ActivityIntensity.moderate:
        return 'moderate';
      case ActivityIntensity.vigorous:
        return 'high'; // Map to backend HIGH enum
    }
  }

  ActivityIntensity _mapBackendActivityIntensity(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return ActivityIntensity.light; // Map from backend LOW enum
      case 'moderate':
        return ActivityIntensity.moderate;
      case 'high':
      case 'very_high': // Also handle VERY_HIGH backend enum
      default:
        return ActivityIntensity.vigorous; // Map from backend HIGH/VERY_HIGH enums
    }
  }

  // Convert activity metrics to backend DTO
  Map<String, dynamic> _activityToDto(ActivityMetrics activity) {
    return {
      'activityType': _mapActivityType(activity.activityType),
      'activityName': activity.activityName,
      'date': activity.date.toIso8601String(),
      'duration': activity.duration?.inMinutes,
      'intensity': _mapActivityIntensity(activity.intensity),
      'caloriesBurned': activity.caloriesBurned,
      'distance': activity.distance,
      'distanceUnit': activity.distanceUnit,
      'steps': activity.steps,
      'averageHeartRate': activity.averageHeartRate,
      'heartRateMax': activity.heartRateMax,
      'notes': activity.notes,
    };
  }

  // Convert backend response to activity metrics
  ActivityMetrics _dtoToActivity(Map<String, dynamic> data) {
    return ActivityMetrics(
      id: data['id']?.toString() ?? '',
      date: DateTime.parse(data['date'] as String),
      activityType: _mapBackendActivityType(data['activityType'] as String),
      activityName: data['activityName'] as String,
      duration: data['duration'] != null ? Duration(minutes: _parseInt(data['duration']) ?? 0) : null,
      intensity: _mapBackendActivityIntensity(data['intensity'] as String),
      caloriesBurned: _parseInt(data['caloriesBurned']),
      distance: _parseDouble(data['distance']),
      distanceUnit: data['distanceUnit'] as String?,
      steps: _parseInt(data['steps']),
      averageHeartRate: _parseInt(data['averageHeartRate']),
      heartRateMax: _parseInt(data['heartRateMax']),
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'] as String) : DateTime.now(),
    );
  }

  // Convert nutrition metrics to backend DTO
  Map<String, dynamic> _nutritionToDto(NutritionMetrics nutrition) {
    return {
      'mealType': _mapMealType(nutrition.mealType),
      'foodName': nutrition.foodName,
      'date': nutrition.date.toIso8601String(),
      'servingSize': nutrition.servingSize,
      'servingUnit': nutrition.servingUnit,
      'calories': nutrition.calories,
      'protein': nutrition.protein,
      'carbs': nutrition.carbs,
      'fats': nutrition.fats,
      'fiber': nutrition.fiber,
      'sugar': nutrition.sugar,
      'sodium': nutrition.sodium,
      'waterIntake': nutrition.waterIntake,
      'notes': nutrition.notes,
    };
  }

  // Convert backend response to nutrition metrics
  NutritionMetrics _dtoToNutrition(Map<String, dynamic> data) {
    return NutritionMetrics(
      id: data['id']?.toString() ?? '',
      date: DateTime.parse(data['date'] as String),
      mealType: _mapBackendMealType(data['mealType'] as String),
      foodName: data['foodName'] as String,
      servingSize: _parseDouble(data['servingSize']) ?? 0.0,
      servingUnit: data['servingUnit'] as String,
      calories: _parseInt(data['calories']),
      protein: _parseDouble(data['protein']),
      carbs: _parseDouble(data['carbs']),
      fats: _parseDouble(data['fats']),
      fiber: _parseDouble(data['fiber']),
      sugar: _parseDouble(data['sugar']),
      sodium: _parseDouble(data['sodium']),
      waterIntake: _parseInt(data['waterIntake']),
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'] as String) : DateTime.now(),
    );
  }

  // Convert sleep metrics to backend DTO
  Map<String, dynamic> _sleepToDto(SleepMetrics sleep) {
    return {
      'date': sleep.date.toIso8601String().split('T')[0], // Just the date part: "2025-07-04"
      'bedTime': sleep.bedTime != null ? _formatTimeOnly(sleep.bedTime!) : null, // "HH:MM"
      'wakeTime': sleep.wakeTime != null ? _formatTimeOnly(sleep.wakeTime!) : null, // "HH:MM"
      'duration': sleep.duration?.inMinutes,
      'quality': _mapSleepQuality(sleep.quality),
      'deepSleepMinutes': sleep.deepSleepMinutes,
      'remSleepMinutes': sleep.remSleepMinutes,
      'awakeDuringNight': sleep.awakeDuringNight,
      'notes': sleep.notes,
    };
  }

  // Helper to format DateTime to time-only string "HH:MM"
  String _formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Convert backend response to sleep metrics
  SleepMetrics _dtoToSleep(Map<String, dynamic> data) {
    final date = DateTime.parse(data['date'] as String);
    
    return SleepMetrics(
      id: data['id']?.toString() ?? '',
      date: date,
      bedTime: data['bedTime'] != null ? _parseTimeWithDate(data['bedTime'] as String, date) : null,
      wakeTime: data['wakeTime'] != null ? _parseTimeWithDate(data['wakeTime'] as String, date) : null,
      duration: data['duration'] != null ? Duration(minutes: _parseInt(data['duration']) ?? 0) : null,
      quality: _mapBackendSleepQuality(data['quality'] as String),
      deepSleepMinutes: _parseInt(data['deepSleepMinutes']),
      remSleepMinutes: _parseInt(data['remSleepMinutes']),
      awakeDuringNight: _parseInt(data['awakeDuringNight']),
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'] as String) : DateTime.now(),
    );
  }

  // Helper to parse time string "HH:MM" with a specific date
  DateTime _parseTimeWithDate(String timeString, DateTime date) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Helper to safely parse double values from backend
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper to safely parse int values from backend
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Activity metrics API methods
  Future<List<ActivityMetrics>> getActivities({
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? activityType,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (activityType != null) queryParams['activityType'] = _mapActivityType(activityType);
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/activity', queryParams: queryParams),
      );

      // Handle both response formats: direct array or wrapped in 'data'
      final activityList = response.containsKey('data') ? response['data'] : response;
      
      return (activityList as List)
          .map((item) => _dtoToActivity(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching activities: $e');
      }
      rethrow;
    }
  }

  Future<ActivityMetrics> createActivity(ActivityMetrics activity) async {
    try {
      final dto = _activityToDto(activity);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('health/activity', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final activityData = response.containsKey('data') ? response['data'] : response;
      
      if (activityData == null) {
        throw Exception('Activity creation failed - no data returned');
      }
      return _dtoToActivity(activityData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating activity: $e');
      }
      rethrow;
    }
  }

  Future<ActivityMetrics> updateActivity(String id, ActivityMetrics activity) async {
    try {
      final dto = _activityToDto(activity);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.put('health/activity/$id', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final activityData = response.containsKey('data') ? response['data'] : response;
      
      if (activityData == null) {
        throw Exception('Activity update failed - no data returned');
      }
      return _dtoToActivity(activityData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating activity: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.delete('health/activity/$id');
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting activity: $e');
      }
      rethrow;
    }
  }

  // Nutrition metrics API methods
  Future<List<NutritionMetrics>> getNutrition({
    DateTime? startDate,
    DateTime? endDate,
    MealType? mealType,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (mealType != null) queryParams['mealType'] = _mapMealType(mealType);
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/nutrition', queryParams: queryParams),
      );

      // Handle both response formats: direct array or wrapped in 'data'
      final nutritionList = response.containsKey('data') ? response['data'] : response;
      
      return (nutritionList as List)
          .map((item) => _dtoToNutrition(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nutrition: $e');
      }
      rethrow;
    }
  }

  Future<NutritionMetrics> createNutrition(NutritionMetrics nutrition) async {
    try {
      final dto = _nutritionToDto(nutrition);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('health/nutrition', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final nutritionData = response.containsKey('data') ? response['data'] : response;
      
      if (nutritionData == null) {
        throw Exception('Nutrition operation failed - no data returned');
      }
      return _dtoToNutrition(nutritionData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating nutrition: $e');
      }
      rethrow;
    }
  }

  Future<NutritionMetrics> updateNutrition(String id, NutritionMetrics nutrition) async {
    try {
      final dto = _nutritionToDto(nutrition);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.put('health/nutrition/$id', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final nutritionData = response.containsKey('data') ? response['data'] : response;
      
      if (nutritionData == null) {
        throw Exception('Nutrition operation failed - no data returned');
      }
      return _dtoToNutrition(nutritionData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating nutrition: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteNutrition(String id) async {
    try {
      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.delete('health/nutrition/$id');
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting nutrition: $e');
      }
      rethrow;
    }
  }

  // Sleep metrics API methods
  Future<List<SleepMetrics>> getSleep({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/sleep', queryParams: queryParams),
      );

      // Handle both response formats: direct array or wrapped in 'data'
      final sleepList = response.containsKey('data') ? response['data'] : response;
      
      return (sleepList as List)
          .map((item) => _dtoToSleep(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sleep: $e');
      }
      rethrow;
    }
  }

  Future<SleepMetrics> createSleep(SleepMetrics sleep) async {
    try {
      final dto = _sleepToDto(sleep);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('health/sleep', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final sleepData = response.containsKey('data') ? response['data'] : response;
      
      if (sleepData == null) {
        throw Exception('Sleep operation failed - no data returned');
      }
      return _dtoToSleep(sleepData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating sleep: $e');
      }
      rethrow;
    }
  }

  Future<SleepMetrics> updateSleep(String id, SleepMetrics sleep) async {
    try {
      final dto = _sleepToDto(sleep);
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.put('health/sleep/$id', body: dto),
      );

      // Handle both response formats: direct object or wrapped in 'data'
      final sleepData = response.containsKey('data') ? response['data'] : response;
      
      if (sleepData == null) {
        throw Exception('Sleep operation failed - no data returned');
      }
      return _dtoToSleep(sleepData as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating sleep: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteSleep(String id) async {
    try {
      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.delete('health/sleep/$id');
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting sleep: $e');
      }
      rethrow;
    }
  }

  // Statistics and analytics
  Future<Map<String, dynamic>> getActivityStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/activity/stats', queryParams: queryParams),
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching activity stats: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getNutritionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/nutrition/stats', queryParams: queryParams),
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching nutrition stats: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSleepStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('health/sleep/stats', queryParams: queryParams),
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sleep stats: $e');
      }
      rethrow;
    }
  }
}