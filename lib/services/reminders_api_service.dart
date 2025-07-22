import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import 'api_client.dart';

class RemindersApiService {
  final ApiClient _apiClient;
  
  RemindersApiService({BuildContext? context}) : _apiClient = ApiClient(context: context);

  bool get isAuthenticated => _apiClient.isAuthenticated;

  // Map frontend enum to backend enum values
  String _mapReminderType(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return 'medication';
      case ReminderType.hydration:
        return 'water';
      case ReminderType.exercise:
        return 'exercise';
      case ReminderType.meditation:
        return 'custom';
      case ReminderType.sleep:
        return 'sleep';
      case ReminderType.meal:
        return 'meal';
      case ReminderType.custom:
        return 'custom';
    }
  }

  ReminderType _mapBackendReminderType(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return ReminderType.medication;
      case 'water':
        return ReminderType.hydration;
      case 'exercise':
        return ReminderType.exercise;
      case 'sleep':
        return ReminderType.sleep;
      case 'meal':
        return ReminderType.meal;
      case 'custom':
      default:
        return ReminderType.custom;
    }
  }

  String _mapReminderFrequency(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'once';
      case ReminderFrequency.daily:
        return 'daily';
      case ReminderFrequency.weekly:
        return 'weekly';
      case ReminderFrequency.custom:
        return 'custom';
    }
  }

  ReminderFrequency _mapBackendReminderFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'once':
        return ReminderFrequency.once;
      case 'daily':
        return ReminderFrequency.daily;
      case 'weekly':
        return ReminderFrequency.weekly;
      case 'custom':
      default:
        return ReminderFrequency.custom;
    }
  }

  // Convert frontend reminder to backend DTO
  Map<String, dynamic> _reminderToDto(Reminder reminder) {
    final dto = {
      'title': reminder.title,
      'type': _mapReminderType(reminder.type),
      'scheduledTime': reminder.scheduledTime.toIso8601String(),
      'frequency': _mapReminderFrequency(reminder.frequency),
      'isEnabled': reminder.isEnabled,
    };

    if (reminder.description != null) {
      dto['description'] = reminder.description!;
    }

    if (reminder.weekdays.isNotEmpty) {
      // Convert from Flutter (1=Monday) to backend (0=Sunday)
      final backendWeekdays = reminder.weekdays.map((day) => day == 7 ? 0 : day).toList();
      dto['weekdays'] = backendWeekdays;
    }

    if (reminder.endDate != null) {
      dto['endDate'] = reminder.endDate!.toIso8601String();
    }

    if (reminder.customData.isNotEmpty) {
      dto['customData'] = reminder.customData;
    }

    return dto;
  }

  // Convert backend response to frontend reminder
  Reminder _dtoToReminder(Map<String, dynamic> data) {
    // Safely parse weekdays - handle both string and int arrays
    final weekdaysData = data['weekdays'] as List<dynamic>? ?? [];
    final weekdays = weekdaysData.map<int>((e) {
      if (e is int) return e;
      if (e is String) {
        final parsed = int.tryParse(e);
        if (parsed != null) return parsed;
      }
      if (e is double) return e.round();
      return 1; // Default to Monday if unparseable
    }).toList();
    // Convert from backend (0=Sunday) to Flutter (1=Monday)
    final flutterWeekdays = weekdays.map((day) => day == 0 ? 7 : day).toList();

    return Reminder(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString(),
      type: _mapBackendReminderType(data['type']?.toString() ?? 'custom'),
      scheduledTime: data['scheduledTime'] != null 
          ? DateTime.tryParse(data['scheduledTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      frequency: _mapBackendReminderFrequency(data['frequency']?.toString() ?? 'once'),
      status: ReminderStatus.active,
      isEnabled: data['isEnabled'] == true || data['isEnabled'] == 'true',
      weekdays: flutterWeekdays,
      endDate: data['endDate'] != null 
          ? DateTime.tryParse(data['endDate'].toString())
          : null,
      customData: data['customData'] is Map<String, dynamic> 
          ? data['customData'] as Map<String, dynamic>
          : {},
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Fetch all reminders
  Future<List<Reminder>> getReminders({
    bool? isEnabled,
    String? status,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (isEnabled != null) queryParams['isEnabled'] = isEnabled.toString();
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('reminders', queryParams: queryParams),
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((item) => _dtoToReminder(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reminders: $e');
      }
      rethrow;
    }
  }

  // Get upcoming reminders
  Future<List<Reminder>> getUpcomingReminders({int? hours}) async {
    try {
      final queryParams = <String, String>{};
      if (hours != null) queryParams['hours'] = hours.toString();

      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('reminders/upcoming', queryParams: queryParams),
      );

      if (response['data'] is List) {
        return (response['data'] as List)
            .map((item) => _dtoToReminder(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching upcoming reminders: $e');
      }
      rethrow;
    }
  }

  // Get reminder statistics
  Future<Map<String, dynamic>> getReminderStats() async {
    try {
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('reminders/stats'),
      );

      return response['data'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reminder stats: $e');
      }
      rethrow;
    }
  }

  // Create a new reminder
  Future<Reminder> createReminder(Reminder reminder) async {
    try {
      final dto = _reminderToDto(reminder);
      
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.post('reminders', body: dto),
      );

      // Handle case where backend returns 201 Created with no response body
      if (response['data'] == null) {
        // Return the original reminder with a generated ID and timestamps
        return reminder.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      return _dtoToReminder(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating reminder: $e');
      }
      rethrow;
    }
  }

  // Update an existing reminder
  Future<Reminder> updateReminder(Reminder reminder) async {
    try {
      final dto = _reminderToDto(reminder);
      
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.patch('reminders/${reminder.id}', body: dto),
      );

      // Handle case where backend returns 200 OK with no response body
      if (response['data'] == null) {
        // Return the updated reminder with current timestamp
        return reminder.copyWith(
          updatedAt: DateTime.now(),
        );
      }

      return _dtoToReminder(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating reminder: $e');
      }
      rethrow;
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.delete('reminders/$reminderId');
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting reminder: $e');
      }
      rethrow;
    }
  }

  // Complete a reminder
  Future<void> completeReminder(String reminderId, {String? note}) async {
    try {
      final body = <String, dynamic>{};
      if (note != null) body['note'] = note;

      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.post('reminders/$reminderId/complete', body: body);
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error completing reminder: $e');
      }
      rethrow;
    }
  }

  // Dismiss a reminder
  Future<void> dismissReminder(String reminderId, {String? note}) async {
    try {
      final body = <String, dynamic>{};
      if (note != null) body['note'] = note;

      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.post('reminders/$reminderId/dismiss', body: body);
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error dismissing reminder: $e');
      }
      rethrow;
    }
  }

  // Snooze a reminder
  Future<void> snoozeReminder(String reminderId, int minutes, {String? note}) async {
    try {
      final body = <String, dynamic>{
        'minutes': minutes,
      };
      if (note != null) body['note'] = note;

      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.post('reminders/$reminderId/snooze', body: body);
          return {};
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error snoozing reminder: $e');
      }
      rethrow;
    }
  }

  // Get a specific reminder
  Future<Reminder?> getReminder(String reminderId) async {
    try {
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.get('reminders/$reminderId'),
      );

      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        return _dtoToReminder(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reminder: $e');
      }
      rethrow;
    }
  }
}