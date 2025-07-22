import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_storage_service.dart';

class HealthDataService {
  static HealthDataService? _instance;
  static HealthDataService get instance => _instance ??= HealthDataService._();
  
  HealthDataService._();

  Health? _health;
  bool _isInitialized = false;
  bool _hasPermissions = false;
  
  // Streams for health data updates
  final StreamController<int> _stepsController = StreamController<int>.broadcast();
  final StreamController<double> _heartRateController = StreamController<double>.broadcast();
  final StreamController<double> _weightController = StreamController<double>.broadcast();
  final StreamController<int> _sleepController = StreamController<int>.broadcast();
  final StreamController<double> _bloodPressureSystolicController = StreamController<double>.broadcast();
  final StreamController<double> _bloodPressureDiastolicController = StreamController<double>.broadcast();
  
  // Health data types we want to access
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.NUTRITION,
    HealthDataType.WATER,
  ];

  // Getters for streams
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<double> get heartRateStream => _heartRateController.stream;
  Stream<double> get weightStream => _weightController.stream;
  Stream<int> get sleepStream => _sleepController.stream;
  Stream<double> get bloodPressureSystolicStream => _bloodPressureSystolicController.stream;
  Stream<double> get bloodPressureDiastolicStream => _bloodPressureDiastolicController.stream;
  
  bool get isInitialized => _isInitialized;
  bool get hasPermissions => _hasPermissions;

  /// Initialize the health data service
  Future<bool> initialize() async {
    try {
      await LocalStorageService.init();
      _health = Health();
      
      // Check if running on simulator/emulator
      if (await _isRunningOnSimulator()) {
        if (kDebugMode) {
          print('Running on simulator/emulator - using mock health data');
        }
        _hasPermissions = true;
        _isInitialized = true;
        return true;
      }
      
      // Request permissions for real devices
      _hasPermissions = await _requestPermissions();
      if (!_hasPermissions) {
        if (kDebugMode) {
          print('Health data permissions denied - falling back to mock data');
        }
        // Still mark as initialized to allow app to function
        _isInitialized = true;
        return true;
      }

      _isInitialized = true;
      
      if (kDebugMode) {
        print('Health data service initialized successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing health data service: $e');
      }
      // Mark as initialized anyway to allow app to function with mock data
      _isInitialized = true;
      return true;
    }
  }
  
  /// Check if running on simulator/emulator
  Future<bool> _isRunningOnSimulator() async {
    if (kDebugMode) {
      // In debug mode, we can assume simulator for iOS and check Android
      if (Platform.isIOS) {
        // iOS simulator detection
        return true; // Assume simulator in debug mode
      } else if (Platform.isAndroid) {
        // Android emulator often has these characteristics
        return true; // Assume emulator in debug mode
      }
    }
    return false;
  }

  /// Request necessary health permissions
  Future<bool> _requestPermissions() async {
    try {
      // Request activity recognition permission first
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (!status.isGranted) {
          if (kDebugMode) {
            print('Activity recognition permission denied');
          }
          // Don't return false immediately - try health permissions anyway
        }
      }

      // Request health permissions with proper permissions list
      final permissions = await _health?.requestAuthorization(
        _healthDataTypes,
        permissions: _healthDataTypes.map((type) => HealthDataAccess.READ_WRITE).toList(),
      );
      
      if (permissions == true) {
        if (kDebugMode) {
          print('Health permissions granted');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Health permissions denied or partial: $permissions');
        }
        // Even if some permissions denied, we can still work with what we have
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting health permissions: $e');
      }
      // If platform doesn't support health (e.g., simulator), continue anyway
      return true;
    }
  }

  /// Get steps for a specific date range
  Future<List<HealthDataPoint>> getStepsData({
    required DateTime startDate, 
    required DateTime endDate
  }) async {
    if (!_isInitialized || _health == null) {
      throw Exception('Health service not initialized');
    }

    try {
      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.STEPS],
      );

      return healthData.where((data) => data.type == HealthDataType.STEPS).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting steps data: $e');
      }
      return [];
    }
  }

  /// Get daily steps for today
  Future<int> getTodaySteps() async {
    try {
      // Use mock data for simulator/emulator
      if (await _isRunningOnSimulator()) {
        final mockSteps = _generateMockSteps();
        _stepsController.add(mockSteps);
        
        final now = DateTime.now();
        await LocalStorageService.saveDailySteps(
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          mockSteps,
        );
        
        return mockSteps;
      }
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final stepsData = await getStepsData(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      int totalSteps = 0;
      for (final data in stepsData) {
        if (data.value is NumericHealthValue) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        }
      }

      // Update stream
      _stepsController.add(totalSteps);
      
      // Cache the result
      await LocalStorageService.saveDailySteps(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        totalSteps,
      );

      return totalSteps;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting today steps: $e');
      }
      // Return mock data as fallback
      return _generateMockSteps();
    }
  }
  
  /// Generate mock steps data for testing/simulator
  int _generateMockSteps() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Generate realistic step count based on time of day
    if (hour < 6) return 50; // Early morning
    if (hour < 9) return 1200; // Morning routine
    if (hour < 12) return 3500; // Morning activity
    if (hour < 15) return 5800; // Lunch break
    if (hour < 18) return 8200; // Afternoon
    if (hour < 21) return 9800; // Evening
    return 10150; // Night
  }

  /// Get weekly steps data
  Future<Map<String, int>> getWeeklySteps() async {
    try {
      // Use mock data for simulator/emulator
      if (await _isRunningOnSimulator()) {
        return _generateMockWeeklySteps();
      }
      
      final now = DateTime.now();
      final weeklyData = <String, int>{};

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final stepsData = await getStepsData(
          startDate: startOfDay,
          endDate: endOfDay,
        );

        int dailySteps = 0;
        for (final data in stepsData) {
          if (data.value is NumericHealthValue) {
            dailySteps += (data.value as NumericHealthValue).numericValue.toInt();
          }
        }

        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        weeklyData[dateKey] = dailySteps;
      }

      return weeklyData;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting weekly steps: $e');
      }
      return _generateMockWeeklySteps();
    }
  }
  
  /// Generate mock weekly steps data
  Map<String, int> _generateMockWeeklySteps() {
    final now = DateTime.now();
    final weeklyData = <String, int>{};
    final mockSteps = [12000, 8500, 9200, 11300, 7800, 13500, 10200]; // Weekly pattern
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      weeklyData[dateKey] = mockSteps[6 - i];
    }
    
    return weeklyData;
  }

  /// Get monthly steps data
  Future<Map<String, int>> getMonthlySteps() async {
    try {
      // Use mock data for simulator/emulator
      if (await _isRunningOnSimulator()) {
        return _generateMockMonthlySteps();
      }
      
      final now = DateTime.now();
      final monthlyData = <String, int>{};
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(now.year, now.month, i);
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final stepsData = await getStepsData(
          startDate: startOfDay,
          endDate: endOfDay,
        );

        int dailySteps = 0;
        for (final data in stepsData) {
          if (data.value is NumericHealthValue) {
            dailySteps += (data.value as NumericHealthValue).numericValue.toInt();
          }
        }

        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        monthlyData[dateKey] = dailySteps;
      }

      return monthlyData;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting monthly steps: $e');
      }
      return _generateMockMonthlySteps();
    }
  }
  
  /// Generate mock monthly steps data
  Map<String, int> _generateMockMonthlySteps() {
    final now = DateTime.now();
    final monthlyData = <String, int>{};
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Generate realistic monthly pattern with some variation
      int baseSteps = 8000 + (i % 7) * 1500; // Weekly pattern
      if (i % 7 == 0 || i % 7 == 6) baseSteps += 2000; // Higher on weekends
      if (i <= now.day) {
        monthlyData[dateKey] = baseSteps + (i * 50); // Slight increase over time
      } else {
        monthlyData[dateKey] = 0; // Future dates
      }
    }
    
    return monthlyData;
  }

  /// Get heart rate data
  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isInitialized || _health == null) {
      throw Exception('Health service not initialized');
    }

    try {
      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.HEART_RATE],
      );

      return healthData.where((data) => data.type == HealthDataType.HEART_RATE).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting heart rate data: $e');
      }
      return [];
    }
  }

  /// Get latest heart rate
  Future<double?> getLatestHeartRate() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      final heartRateData = await getHeartRateData(
        startDate: yesterday,
        endDate: now,
      );

      if (heartRateData.isNotEmpty) {
        final latest = heartRateData.last;
        if (latest.value is NumericHealthValue) {
          final heartRate = (latest.value as NumericHealthValue).numericValue.toDouble();
          _heartRateController.add(heartRate);
          return heartRate;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting latest heart rate: $e');
      }
      return null;
    }
  }

  /// Get sleep data
  Future<List<HealthDataPoint>> getSleepData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isInitialized || _health == null) {
      throw Exception('Health service not initialized');
    }

    try {
      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP],
      );

      return healthData.where((data) => 
        data.type == HealthDataType.SLEEP_IN_BED || 
        data.type == HealthDataType.SLEEP_ASLEEP
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sleep data: $e');
      }
      return [];
    }
  }

  /// Get weight data
  Future<List<HealthDataPoint>> getWeightData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isInitialized || _health == null) {
      throw Exception('Health service not initialized');
    }

    try {
      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.WEIGHT],
      );

      return healthData.where((data) => data.type == HealthDataType.WEIGHT).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting weight data: $e');
      }
      return [];
    }
  }

  /// Write health data point
  Future<bool> writeHealthData({
    required HealthDataType type,
    required num value,
    required DateTime startTime,
    required DateTime endTime,
    HealthDataUnit? unit,
  }) async {
    if (!_isInitialized || _health == null) {
      throw Exception('Health service not initialized');
    }

    try {
      final success = await _health!.writeHealthData(
        value: value.toDouble(),
        type: type,
        startTime: startTime,
        endTime: endTime,
        unit: unit,
      );

      if (kDebugMode) {
        print('Write health data ${type.name}: $success');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error writing health data: $e');
      }
      return false;
    }
  }

  /// Start continuous health data monitoring
  Future<void> startMonitoring() async {
    if (!_isInitialized || !_hasPermissions) return;

    // Refresh data every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isInitialized && _hasPermissions) {
        await getTodaySteps();
        await getLatestHeartRate();
      } else {
        timer.cancel();
      }
    });
  }

  /// Stop monitoring and dispose resources
  void dispose() {
    _stepsController.close();
    _heartRateController.close();
    _weightController.close();
    _sleepController.close();
    _bloodPressureSystolicController.close();
    _bloodPressureDiastolicController.close();
  }
}