import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_storage_service.dart';

class StepsCounterService {
  static StepsCounterService? _instance;
  static StepsCounterService get instance => _instance ??= StepsCounterService._();
  
  StepsCounterService._();

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;
  
  int _currentSteps = 0;
  int _dailySteps = 0;
  int _baselineSteps = 0;
  bool _isListening = false;
  bool _hasPermission = false;
  PedestrianStatus? _pedestrianStatus;
  
  final StreamController<int> _stepsController = StreamController<int>.broadcast();
  final StreamController<PedestrianStatus> _statusController = StreamController<PedestrianStatus>.broadcast();

  // Getters
  int get currentSteps => _currentSteps;
  int get dailySteps => _dailySteps;
  bool get isListening => _isListening;
  bool get hasPermission => _hasPermission;
  PedestrianStatus? get pedestrianStatus => _pedestrianStatus;
  
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<PedestrianStatus> get statusStream => _statusController.stream;

  // Initialize the service
  Future<bool> initialize() async {
    try {
      await LocalStorageService.init();
      
      // Request permissions
      _hasPermission = await _requestPermissions();
      if (!_hasPermission) {
        if (kDebugMode) {
          print('Steps counter permission denied');
        }
        return false;
      }

      // Load today's steps from storage
      await _loadTodaysSteps();
      
      if (kDebugMode) {
        print('Steps counter service initialized successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing steps counter service: $e');
      }
      return false;
    }
  }

  // Request necessary permissions
  Future<bool> _requestPermissions() async {
    try {
      // Request activity recognition permission
      final status = await Permission.activityRecognition.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Open app settings if permanently denied
        await openAppSettings();
        return false;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permissions: $e');
      }
      return false;
    }
  }

  // Start listening to step counter
  Future<bool> startListening() async {
    if (_isListening || !_hasPermission) return false;

    try {
      // Listen to step count stream
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      // Listen to pedestrian status stream
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      _isListening = true;
      
      if (kDebugMode) {
        print('Started listening to step counter');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting step counter: $e');
      }
      return false;
    }
  }

  // Stop listening to step counter
  void stopListening() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    _stepCountStream = null;
    _pedestrianStatusStream = null;
    _isListening = false;
    
    if (kDebugMode) {
      print('Stopped listening to step counter');
    }
  }

  // Handle step count updates
  void _onStepCount(StepCount event) async {
    try {
      _currentSteps = event.steps;
      
      // Calculate daily steps (reset baseline at midnight)
      if (_baselineSteps == 0) {
        _baselineSteps = _currentSteps - _dailySteps;
      }
      
      final newDailySteps = _currentSteps - _baselineSteps;
      
      if (newDailySteps != _dailySteps) {
        _dailySteps = newDailySteps.clamp(0, double.infinity).toInt();
        
        // Save to local storage
        await _saveTodaysSteps();
        
        // Notify listeners
        _stepsController.add(_dailySteps);
        
        if (kDebugMode) {
          print('Steps updated: $_dailySteps (total: $_currentSteps, baseline: $_baselineSteps)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling step count: $e');
      }
    }
  }

  // Handle step count errors
  void _onStepCountError(Object error) {
    if (kDebugMode) {
      print('Step count error: $error');
    }
    
    // Try to restart listening after a delay
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isListening) {
        startListening();
      }
    });
  }

  // Handle pedestrian status changes
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _pedestrianStatus = event;
    _statusController.add(event);
    
    if (kDebugMode) {
      print('Pedestrian status changed: ${event.status}');
    }
  }

  // Handle pedestrian status errors
  void _onPedestrianStatusError(Object error) {
    if (kDebugMode) {
      print('Pedestrian status error: $error');
    }
  }

  // Load today's steps from storage
  Future<void> _loadTodaysSteps() async {
    try {
      final today = _getTodayDateString();
      _dailySteps = await LocalStorageService.getDailySteps(today);
      
      if (kDebugMode) {
        print('Loaded today\'s steps from storage: $_dailySteps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading today\'s steps: $e');
      }
    }
  }

  // Save today's steps to storage
  Future<void> _saveTodaysSteps() async {
    try {
      final today = _getTodayDateString();
      await LocalStorageService.saveDailySteps(today, _dailySteps);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving today\'s steps: $e');
      }
    }
  }

  // Reset daily steps (called at midnight)
  Future<void> resetDailySteps() async {
    try {
      // Save final count for yesterday
      final yesterday = _getYesterdayDateString();
      await LocalStorageService.saveDailySteps(yesterday, _dailySteps);
      
      // Reset for today
      _dailySteps = 0;
      _baselineSteps = _currentSteps;
      
      // Save reset count for today
      await _saveTodaysSteps();
      
      // Notify listeners
      _stepsController.add(_dailySteps);
      
      if (kDebugMode) {
        print('Daily steps reset for new day');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting daily steps: $e');
      }
    }
  }

  // Get weekly steps data
  Future<Map<String, int>> getWeeklySteps() async {
    return await LocalStorageService.getWeeklySteps();
  }

  // Get steps for a specific date
  Future<int> getStepsForDate(DateTime date) async {
    final dateString = _formatDateString(date);
    return await LocalStorageService.getDailySteps(dateString);
  }

  // Manual step adjustment (for testing or corrections)
  Future<void> adjustDailySteps(int adjustment) async {
    _dailySteps = (_dailySteps + adjustment).clamp(0, double.infinity).toInt();
    await _saveTodaysSteps();
    _stepsController.add(_dailySteps);
    
    if (kDebugMode) {
      print('Manually adjusted daily steps by $adjustment. New total: $_dailySteps');
    }
  }

  // Check if step counting is supported on this device
  static Future<bool> isSupported() async {
    try {
      // Try to access the step count stream briefly
      final subscription = Pedometer.stepCountStream.listen(null);
      await Future.delayed(const Duration(milliseconds: 100));
      subscription.cancel();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Step counting not supported: $e');
      }
      return false;
    }
  }

  // Utility methods
  String _getTodayDateString() {
    return _formatDateString(DateTime.now());
  }

  String _getYesterdayDateString() {
    return _formatDateString(DateTime.now().subtract(const Duration(days: 1)));
  }

  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Dispose resources
  void dispose() {
    stopListening();
    _stepsController.close();
    _statusController.close();
  }
}