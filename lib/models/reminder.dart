
enum ReminderType {
  medication,
  hydration,
  exercise,
  meditation,
  sleep,
  meal,
  custom,
}

enum ReminderFrequency {
  once,
  daily,
  weekly,
  custom,
}

enum ReminderStatus {
  active,
  paused,
  completed,
  dismissed,
}

class Reminder {
  final String id;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime scheduledTime;
  final ReminderFrequency frequency;
  final ReminderStatus status;
  final bool isEnabled;
  final List<int> weekdays; // 1-7 for Monday-Sunday
  final DateTime? endDate;
  final Map<String, dynamic> customData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.scheduledTime,
    this.frequency = ReminderFrequency.once,
    this.status = ReminderStatus.active,
    this.isEnabled = true,
    this.weekdays = const [],
    this.endDate,
    this.customData = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledTime,
    ReminderFrequency? frequency,
    ReminderStatus? status,
    bool? isEnabled,
    List<int>? weekdays,
    DateTime? endDate,
    Map<String, dynamic>? customData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      weekdays: weekdays ?? this.weekdays,
      endDate: endDate ?? this.endDate,
      customData: customData ?? this.customData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'scheduledTime': scheduledTime.toIso8601String(),
      'frequency': frequency.name,
      'status': status.name,
      'isEnabled': isEnabled,
      'weekdays': weekdays,
      'endDate': endDate?.toIso8601String(),
      'customData': customData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse weekdays from various formats
    List<int> parseWeekdays(dynamic weekdaysData) {
      if (weekdaysData == null) return [];
      
      if (weekdaysData is List) {
        return weekdaysData.map<int>((e) {
          if (e is int) return e;
          if (e is String) {
            final parsed = int.tryParse(e);
            if (parsed != null) return parsed;
          }
          if (e is double) return e.round();
          return 1; // Default to Monday if unparseable
        }).toList();
      }
      
      if (weekdaysData is String) {
        // Handle comma-separated string like "1,2,3"
        try {
          return weekdaysData.split(',')
              .map((e) => int.tryParse(e.trim()) ?? 1)
              .toList();
        } catch (e) {
          return [1]; // Default to Monday
        }
      }
      
      return [];
    }
    
    // Helper function to safely parse enum
    T parseEnum<T>(List<T> values, dynamic value, T defaultValue) {
      if (value == null) return defaultValue;
      
      final stringValue = value.toString();
      try {
        return values.firstWhere(
          (enumValue) => enumValue.toString().split('.').last == stringValue,
          orElse: () => defaultValue,
        );
      } catch (e) {
        return defaultValue;
      }
    }
    
    return Reminder(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      type: parseEnum(ReminderType.values, json['type'], ReminderType.custom),
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.tryParse(json['scheduledTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      frequency: parseEnum(ReminderFrequency.values, json['frequency'], ReminderFrequency.once),
      status: parseEnum(ReminderStatus.values, json['status'], ReminderStatus.active),
      isEnabled: json['isEnabled'] == true || json['isEnabled'] == 'true',
      weekdays: parseWeekdays(json['weekdays']),
      endDate: json['endDate'] != null 
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      customData: json['customData'] is Map<String, dynamic> 
          ? json['customData'] as Map<String, dynamic>
          : {},
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Helper methods
  String get typeLabel {
    switch (type) {
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.hydration:
        return 'Hydration';
      case ReminderType.exercise:
        return 'Exercise';
      case ReminderType.meditation:
        return 'Meditation';
      case ReminderType.sleep:
        return 'Sleep';
      case ReminderType.meal:
        return 'Meal';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  bool get isRecurring => frequency != ReminderFrequency.once;

  DateTime? get nextScheduledTime {
    if (!isEnabled || status != ReminderStatus.active) return null;
    
    final now = DateTime.now();
    if (frequency == ReminderFrequency.once) {
      return scheduledTime.isAfter(now) ? scheduledTime : null;
    }
    
    // Calculate next occurrence for recurring reminders
    DateTime next = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    
    if (frequency == ReminderFrequency.daily) {
      if (next.isBefore(now)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }
    
    if (frequency == ReminderFrequency.weekly && weekdays.isNotEmpty) {
      // Find next weekday
      for (int i = 0; i < 7; i++) {
        final testDate = next.add(Duration(days: i));
        if (weekdays.contains(testDate.weekday) && 
            (testDate.isAfter(now) || (testDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute)) && testDate.isAfter(now)))) {
          return testDate;
        }
      }
    }
    
    return null;
  }

  bool get isOverdue {
    final next = nextScheduledTime;
    if (next == null) return false;
    return next.isBefore(DateTime.now());
  }
}

class ReminderAction {
  final String id;
  final String reminderId;
  final DateTime actionTime;
  final ReminderActionType actionType;
  final String? note;

  const ReminderAction({
    required this.id,
    required this.reminderId,
    required this.actionTime,
    required this.actionType,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderId': reminderId,
      'actionTime': actionTime.toIso8601String(),
      'actionType': actionType.name,
      'note': note,
    };
  }

  factory ReminderAction.fromJson(Map<String, dynamic> json) {
    return ReminderAction(
      id: json['id'] as String,
      reminderId: json['reminderId'] as String,
      actionTime: DateTime.parse(json['actionTime'] as String),
      actionType: ReminderActionType.values.firstWhere((type) => type.name == json['actionType']),
      note: json['note'] as String?,
    );
  }
}

enum ReminderActionType {
  completed,
  dismissed,
  snoozed,
  missed,
}