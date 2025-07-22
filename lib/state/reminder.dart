import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminders_api_service.dart';

class ReminderState extends ChangeNotifier {
  RemindersApiService? _apiService;
  BuildContext? _lastContext;
  List<Reminder> _reminders = [];
  final List<ReminderAction> _reminderActions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Initialize API service with context
  void initializeApiService(BuildContext context) {
    // Only reinitialize if context has changed or service is null
    if (_apiService == null || _lastContext != context) {
      _lastContext = context;
      _apiService = RemindersApiService(context: context);
    }
  }

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<ReminderAction> get reminderActions => List.unmodifiable(_reminderActions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get active reminders
  List<Reminder> get activeReminders => _reminders
      .where((reminder) => reminder.isEnabled && reminder.status == ReminderStatus.active)
      .toList();

  // Get upcoming reminders (next 24 hours)
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return activeReminders.where((reminder) {
      final next = reminder.nextScheduledTime;
      return next != null && next.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) {
        final aNext = a.nextScheduledTime!;
        final bNext = b.nextScheduledTime!;
        return aNext.compareTo(bNext);
      });
  }

  // Get overdue reminders
  List<Reminder> get overdueReminders => activeReminders
      .where((reminder) => reminder.isOverdue)
      .toList();

  // Get reminders by type
  List<Reminder> getRemindersByType(ReminderType type) =>
      activeReminders.where((reminder) => reminder.type == type).toList();

  // Load reminders from backend only
  Future<void> loadReminders() async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiService == null) {
        _reminders = [];
        _reminderActions.clear();
        _setError('API service not initialized. Call initializeApiService() first.');
        return;
      }

      // Wait a bit for authentication to settle if it's still loading
      int retryCount = 0;
      bool isAuthenticated = false;
      
      while (retryCount < 5) {
        try {
          isAuthenticated = _apiService!.isAuthenticated;
          if (isAuthenticated) break;
        } catch (e) {
          // Context might be deactivated, break early
          if (kDebugMode) {
            print('Auth check failed during retry $retryCount: $e');
          }
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }

      if (!isAuthenticated) {
        _reminders = [];
        _reminderActions.clear();
        _setError('Not authenticated - please sign in to view reminders');
        return;
      }

      final apiReminders = await _apiService!.getReminders();
      _reminders = apiReminders;
      
      if (kDebugMode) {
        print('Successfully loaded ${apiReminders.length} reminders from backend');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load reminders: $e');
      }
      _setError('Failed to load reminders: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add reminder directly to backend
  Future<bool> addReminder(Reminder reminder) async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      final createdReminder = await _apiService!.createReminder(reminder);
      _reminders.add(createdReminder);
      
      if (kDebugMode) {
        print('Successfully created reminder: ${createdReminder.title}');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add reminder: $e');
      
      if (kDebugMode) {
        print('Error adding reminder: $e');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update reminder directly in backend
  Future<bool> updateReminder(Reminder updatedReminder) async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      final updated = await _apiService!.updateReminder(updatedReminder);
      final index = _reminders.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _reminders[index] = updated;
        notifyListeners();
      }
      
      if (kDebugMode) {
        print('Successfully updated reminder: ${updated.title}');
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update reminder: $e');
      
      if (kDebugMode) {
        print('Error updating reminder: $e');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete reminder directly from backend
  Future<bool> deleteReminder(String reminderId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      await _apiService!.deleteReminder(reminderId);
      _reminders.removeWhere((r) => r.id == reminderId);
      _reminderActions.removeWhere((a) => a.reminderId == reminderId);
      
      if (kDebugMode) {
        print('Successfully deleted reminder: $reminderId');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete reminder: $e');
      
      if (kDebugMode) {
        print('Error deleting reminder: $e');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle reminder enabled status
  Future<bool> toggleReminder(String reminderId) async {
    final reminder = _reminders.firstWhere((r) => r.id == reminderId);
    return updateReminder(reminder.copyWith(isEnabled: !reminder.isEnabled));
  }

  // Complete reminder via backend
  Future<bool> completeReminder(String reminderId, {String? note}) async {
    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      await _apiService!.completeReminder(reminderId, note: note);

      // Add action locally for UI
      final action = ReminderAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reminderId: reminderId,
        actionTime: DateTime.now(),
        actionType: ReminderActionType.completed,
        note: note,
      );
      _reminderActions.add(action);
      
      // Update reminder status if it's a one-time reminder
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      if (reminder.frequency == ReminderFrequency.once) {
        final index = _reminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          _reminders[index] = reminder.copyWith(status: ReminderStatus.completed);
        }
      }
      
      if (kDebugMode) {
        print('Successfully completed reminder: $reminderId');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to complete reminder: $e');
      
      if (kDebugMode) {
        print('Error completing reminder: $e');
      }
      
      return false;
    }
  }

  // Dismiss reminder via backend
  Future<bool> dismissReminder(String reminderId, {String? note}) async {
    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      await _apiService!.dismissReminder(reminderId, note: note);

      // Add action locally for UI
      final action = ReminderAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reminderId: reminderId,
        actionTime: DateTime.now(),
        actionType: ReminderActionType.dismissed,
        note: note,
      );
      _reminderActions.add(action);
      
      if (kDebugMode) {
        print('Successfully dismissed reminder: $reminderId');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to dismiss reminder: $e');
      
      if (kDebugMode) {
        print('Error dismissing reminder: $e');
      }
      
      return false;
    }
  }

  // Snooze reminder via backend
  Future<bool> snoozeReminder(String reminderId, Duration snoozeDuration) async {
    try {
      if (_apiService == null) {
        _setError('API service not initialized. Call initializeApiService() first.');
        return false;
      }

      if (!_apiService!.isAuthenticated) {
        _setError('Not authenticated');
        return false;
      }

      await _apiService!.snoozeReminder(reminderId, snoozeDuration.inMinutes);

      // Add action locally for UI
      final action = ReminderAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reminderId: reminderId,
        actionTime: DateTime.now(),
        actionType: ReminderActionType.snoozed,
        note: 'Snoozed for ${snoozeDuration.inMinutes} minutes',
      );
      _reminderActions.add(action);
      
      // Update local reminder with new scheduled time
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      final newTime = DateTime.now().add(snoozeDuration);
      return updateReminder(reminder.copyWith(scheduledTime: newTime));
    } catch (e) {
      _setError('Failed to snooze reminder: $e');
      
      if (kDebugMode) {
        print('Error snoozing reminder: $e');
      }
      
      return false;
    }
  }

  // Get reminder statistics from backend
  Map<String, dynamic> getReminderStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final recentActions = _reminderActions
        .where((action) => action.actionTime.isAfter(weekAgo))
        .toList();
    
    final completed = recentActions
        .where((action) => action.actionType == ReminderActionType.completed)
        .length;
    
    final dismissed = recentActions
        .where((action) => action.actionType == ReminderActionType.dismissed)
        .length;
    
    final total = recentActions.length;
    final completionRate = total > 0 ? (completed / total * 100).round() : 0;
    
    return {
      'totalReminders': _reminders.length,
      'activeReminders': activeReminders.length,
      'upcomingReminders': upcomingReminders.length,
      'overdueReminders': overdueReminders.length,
      'weeklyCompletion': completed,
      'weeklyDismissed': dismissed,
      'completionRate': completionRate,
    };
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