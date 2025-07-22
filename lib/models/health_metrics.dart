import 'package:flutter/foundation.dart';

enum SleepQuality {
  poor,
  fair,
  good,
  excellent,
}

enum MoodLevel {
  veryLow,
  low,
  neutral,
  good,
  excellent,
}

enum ActivityType {
  walking,
  running,
  cycling,
  swimming,
  weightLifting,
  workout,
  yoga,
  pilates,
  sports,
  other,
}

enum ActivityIntensity {
  light,
  moderate,
  vigorous,
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

class SleepMetrics {
  final String id;
  final DateTime date;
  final DateTime? bedTime;
  final DateTime? wakeTime;
  final Duration? duration;
  final SleepQuality quality;
  final int? deepSleepMinutes;
  final int? remSleepMinutes;
  final int? awakeDuringNight;
  final String? notes;
  final DateTime createdAt;

  const SleepMetrics({
    required this.id,
    required this.date,
    this.bedTime,
    this.wakeTime,
    this.duration,
    required this.quality,
    this.deepSleepMinutes,
    this.remSleepMinutes,
    this.awakeDuringNight,
    this.notes,
    required this.createdAt,
  });

  double get sleepEfficiency {
    if (duration == null || bedTime == null || wakeTime == null) return 0.0;
    final timeInBed = wakeTime!.difference(bedTime!);
    return (duration!.inMinutes / timeInBed.inMinutes) * 100;
  }

  SleepMetrics copyWith({
    String? id,
    DateTime? date,
    DateTime? bedTime,
    DateTime? wakeTime,
    Duration? duration,
    SleepQuality? quality,
    int? deepSleepMinutes,
    int? remSleepMinutes,
    int? awakeDuringNight,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepMetrics(
      id: id ?? this.id,
      date: date ?? this.date,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
      awakeDuringNight: awakeDuringNight ?? this.awakeDuringNight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bedTime': bedTime?.toIso8601String(),
      'wakeTime': wakeTime?.toIso8601String(),
      'duration': duration?.inMinutes,
      'quality': quality.name,
      'deepSleepMinutes': deepSleepMinutes,
      'remSleepMinutes': remSleepMinutes,
      'awakeDuringNight': awakeDuringNight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepMetrics.fromJson(Map<String, dynamic> json) {
    return SleepMetrics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      bedTime: json['bedTime'] != null ? DateTime.parse(json['bedTime'] as String) : null,
      wakeTime: json['wakeTime'] != null ? DateTime.parse(json['wakeTime'] as String) : null,
      duration: json['duration'] != null ? Duration(minutes: json['duration'] as int) : null,
      quality: SleepQuality.values.firstWhere((q) => q.name == json['quality']),
      deepSleepMinutes: json['deepSleepMinutes'] as int?,
      remSleepMinutes: json['remSleepMinutes'] as int?,
      awakeDuringNight: json['awakeDuringNight'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NutritionMetrics {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String foodName;
  final double servingSize;
  final String servingUnit;
  final int? calories;
  final double? protein; // grams
  final double? carbs; // grams
  final double? fats; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? sodium; // mg
  final int? waterIntake; // ml
  final String? notes;
  final DateTime createdAt;

  const NutritionMetrics({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.servingSize,
    required this.servingUnit,
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.fiber,
    this.sugar,
    this.sodium,
    this.waterIntake,
    this.notes,
    required this.createdAt,
  });

  NutritionMetrics copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? foodName,
    double? servingSize,
    String? servingUnit,
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    double? sugar,
    double? sodium,
    int? waterIntake,
    String? notes,
    DateTime? createdAt,
  }) {
    return NutritionMetrics(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      waterIntake: waterIntake ?? this.waterIntake,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.name,
      'foodName': foodName,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'waterIntake': waterIntake,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NutritionMetrics.fromJson(Map<String, dynamic> json) {
    return NutritionMetrics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: MealType.values.firstWhere((type) => type.name == json['mealType']),
      foodName: json['foodName'] as String,
      servingSize: json['servingSize']?.toDouble() ?? 0.0,
      servingUnit: json['servingUnit'] as String,
      calories: json['calories'] as int?,
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      fats: json['fats']?.toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      waterIntake: json['waterIntake'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ActivityMetrics {
  final String id;
  final DateTime date;
  final ActivityType activityType;
  final String activityName;
  final Duration? duration;
  final ActivityIntensity intensity;
  final int? caloriesBurned;
  final double? distance; // km
  final String? distanceUnit;
  final int? steps;
  final int? averageHeartRate;
  final int? heartRateMax;
  final String? notes;
  final DateTime createdAt;

  const ActivityMetrics({
    required this.id,
    required this.date,
    required this.activityType,
    required this.activityName,
    this.duration,
    required this.intensity,
    this.caloriesBurned,
    this.distance,
    this.distanceUnit,
    this.steps,
    this.averageHeartRate,
    this.heartRateMax,
    this.notes,
    required this.createdAt,
  });

  double? get pace {
    if (distance == null || duration?.inMinutes == 0) return null;
    return duration!.inMinutes / distance!; // minutes per km
  }

  ActivityMetrics copyWith({
    String? id,
    DateTime? date,
    ActivityType? activityType,
    String? activityName,
    Duration? duration,
    ActivityIntensity? intensity,
    int? caloriesBurned,
    double? distance,
    String? distanceUnit,
    int? steps,
    int? averageHeartRate,
    int? heartRateMax,
    String? notes,
    DateTime? createdAt,
  }) {
    return ActivityMetrics(
      id: id ?? this.id,
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      activityName: activityName ?? this.activityName,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distance: distance ?? this.distance,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      steps: steps ?? this.steps,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'activityType': activityType.name,
      'activityName': activityName,
      'duration': duration?.inMinutes,
      'intensity': intensity.name,
      'caloriesBurned': caloriesBurned,
      'distance': distance,
      'distanceUnit': distanceUnit,
      'steps': steps,
      'averageHeartRate': averageHeartRate,
      'heartRateMax': heartRateMax,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityMetrics.fromJson(Map<String, dynamic> json) {
    return ActivityMetrics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      activityType: ActivityType.values.firstWhere((type) => type.name == json['activityType']),
      activityName: json['activityName'] as String,
      duration: json['duration'] != null ? Duration(minutes: json['duration'] as int) : null,
      intensity: ActivityIntensity.values.firstWhere((intensity) => intensity.name == json['intensity']),
      caloriesBurned: json['caloriesBurned'] as int?,
      distance: json['distance']?.toDouble(),
      distanceUnit: json['distanceUnit'] as String?,
      steps: json['steps'] as int?,
      averageHeartRate: json['averageHeartRate'] as int?,
      heartRateMax: json['heartRateMax'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class DailyHealthSummary {
  final String id;
  final String userId;
  final DateTime date;
  final MoodLevel mood;
  final int stressLevel; // 1-10 scale
  final int energyLevel; // 1-10 scale
  final List<String> symptoms;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? weight; // kg
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyHealthSummary({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.stressLevel,
    required this.energyLevel,
    this.symptoms = const [],
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.weight,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  DailyHealthSummary copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodLevel? mood,
    int? stressLevel,
    int? energyLevel,
    List<String>? symptoms,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? weight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyHealthSummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      symptoms: symptoms ?? this.symptoms,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'symptoms': symptoms,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'weight': weight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyHealthSummary.fromJson(Map<String, dynamic> json) {
    return DailyHealthSummary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodLevel.values.firstWhere((mood) => mood.name == json['mood']),
      stressLevel: json['stressLevel'] as int,
      energyLevel: json['energyLevel'] as int,
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      bloodPressureSystolic: json['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as int?,
      weight: json['weight']?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyHealthSummary &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.mood == mood &&
        other.stressLevel == stressLevel &&
        other.energyLevel == energyLevel &&
        listEquals(other.symptoms, symptoms) &&
        other.bloodPressureSystolic == bloodPressureSystolic &&
        other.bloodPressureDiastolic == bloodPressureDiastolic &&
        other.weight == weight &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      date,
      mood,
      stressLevel,
      energyLevel,
      Object.hashAll(symptoms),
      bloodPressureSystolic,
      bloodPressureDiastolic,
      weight,
      notes,
    );
  }
}