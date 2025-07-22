import 'package:flutter/foundation.dart';

enum HealthCondition {
  adhd,
  anxiety,
  depression,
  diabetes,
  hypertension,
  sleepDisorders,
  heartDisease,
  obesity,
  none,
}

enum CulturalDiet {
  mediterranean,
  asian,
  african,
  latinAmerican,
  middleEastern,
  vegetarian,
  vegan,
  keto,
  paleo,
  halal,
  kosher,
  none,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final List<HealthCondition> healthConditions;
  final List<CulturalDiet> culturalDietPreferences;
  final ActivityLevel activityLevel;
  final List<String> allergies;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.healthConditions = const [],
    this.culturalDietPreferences = const [],
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.allergies = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  bool get hasHealthConditions => healthConditions.isNotEmpty;

  bool get hasSleepIssues => healthConditions.contains(HealthCondition.sleepDisorders);

  bool get hasAdhd => healthConditions.contains(HealthCondition.adhd);

  bool get hasHypertension => healthConditions.contains(HealthCondition.hypertension);

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    List<HealthCondition>? healthConditions,
    List<CulturalDiet>? culturalDietPreferences,
    ActivityLevel? activityLevel,
    List<String>? allergies,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      healthConditions: healthConditions ?? this.healthConditions,
      culturalDietPreferences: culturalDietPreferences ?? this.culturalDietPreferences,
      activityLevel: activityLevel ?? this.activityLevel,
      allergies: allergies ?? this.allergies,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'healthConditions': healthConditions.map((e) => e.name).toList(),
      'culturalDietPreferences': culturalDietPreferences.map((e) => e.name).toList(),
      'activityLevel': activityLevel.name,
      'allergies': allergies,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      healthConditions: (json['healthConditions'] as List<dynamic>?)
              ?.map((e) => HealthCondition.values
                  .firstWhere((condition) => condition.name == e))
              .toList() ??
          [],
      culturalDietPreferences: (json['culturalDietPreferences'] as List<dynamic>?)
              ?.map((e) => CulturalDiet.values
                  .firstWhere((diet) => diet.name == e))
              .toList() ??
          [],
      activityLevel: ActivityLevel.values
          .firstWhere((level) => level.name == json['activityLevel'], orElse: () => ActivityLevel.moderatelyActive),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.dateOfBirth == dateOfBirth &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        listEquals(other.healthConditions, healthConditions) &&
        listEquals(other.culturalDietPreferences, culturalDietPreferences) &&
        other.activityLevel == activityLevel &&
        listEquals(other.allergies, allergies) &&
        mapEquals(other.preferences, preferences) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      dateOfBirth,
      gender,
      height,
      weight,
      Object.hashAll(healthConditions),
      Object.hashAll(culturalDietPreferences),
      activityLevel,
      Object.hashAll(allergies),
      preferences,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, healthConditions: $healthConditions, culturalDietPreferences: $culturalDietPreferences)';
  }
}