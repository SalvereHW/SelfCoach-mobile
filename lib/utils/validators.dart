import 'package:intl/intl.dart';

class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Numeric validation
  static String? number(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    final numberValidation = number(value, fieldName: fieldName);
    if (numberValidation != null) return numberValidation;
    
    final numberValue = double.parse(value!);
    if (numberValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  // Weight validation (kg)
  static String? weight(String? value) {
    final weightValidation = positiveNumber(value, fieldName: 'Weight');
    if (weightValidation != null) return weightValidation;
    
    final weight = double.parse(value!);
    if (weight < 20 || weight > 500) {
      return 'Please enter a realistic weight (20-500 kg)';
    }
    
    return null;
  }

  // Height validation (cm)
  static String? height(String? value) {
    final heightValidation = positiveNumber(value, fieldName: 'Height');
    if (heightValidation != null) return heightValidation;
    
    final height = double.parse(value!);
    if (height < 50 || height > 300) {
      return 'Please enter a realistic height (50-300 cm)';
    }
    
    return null;
  }

  // Age validation
  static String? age(String? value) {
    final ageValidation = positiveNumber(value, fieldName: 'Age');
    if (ageValidation != null) return ageValidation;
    
    final age = int.parse(value!);
    if (age < 1 || age > 150) {
      return 'Please enter a realistic age (1-150 years)';
    }
    
    return null;
  }

  // Date validation
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
    } catch (e) {
      return 'Please enter a valid date';
    }
    
    return null;
  }

  // Past date validation
  static String? pastDate(String? value) {
    final dateValidation = date(value);
    if (dateValidation != null) return dateValidation;
    
    final inputDate = DateTime.parse(value!);
    final now = DateTime.now();
    
    if (inputDate.isAfter(now)) {
      return 'Date cannot be in the future';
    }
    
    return null;
  }

  // Time validation (HH:mm format)
  static String? time(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter time in HH:mm format';
    }
    
    return null;
  }

  // Sleep duration validation (hours)
  static String? sleepDuration(String? value) {
    final durationValidation = positiveNumber(value, fieldName: 'Sleep duration');
    if (durationValidation != null) return durationValidation;
    
    final duration = double.parse(value!);
    if (duration > 24) {
      return 'Sleep duration cannot exceed 24 hours';
    }
    
    if (duration < 0.5) {
      return 'Sleep duration must be at least 30 minutes';
    }
    
    return null;
  }

  // Calories validation
  static String? calories(String? value) {
    final caloriesValidation = positiveNumber(value, fieldName: 'Calories');
    if (caloriesValidation != null) return caloriesValidation;
    
    final calories = int.parse(value!);
    if (calories > 10000) {
      return 'Calories seem too high. Please check your input';
    }
    
    return null;
  }

  // Serving size validation
  static String? servingSize(String? value) {
    final servingValidation = positiveNumber(value, fieldName: 'Serving size');
    if (servingValidation != null) return servingValidation;
    
    final serving = double.parse(value!);
    if (serving > 1000) {
      return 'Serving size seems too large. Please check your input';
    }
    
    return null;
  }

  // Exercise duration validation (minutes)
  static String? exerciseDuration(String? value) {
    final durationValidation = positiveNumber(value, fieldName: 'Exercise duration');
    if (durationValidation != null) return durationValidation;
    
    final duration = int.parse(value!);
    if (duration > 1440) { // 24 hours in minutes
      return 'Exercise duration cannot exceed 24 hours';
    }
    
    return null;
  }

  // Activity duration validation (alias for exerciseDuration)
  static String? activityDuration(String? value) {
    return exerciseDuration(value);
  }

  // Distance validation (km)
  static String? distance(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final distanceValidation = positiveNumber(value, fieldName: 'Distance');
    if (distanceValidation != null) return distanceValidation;
    
    final distance = double.parse(value);
    if (distance > 1000) {
      return 'Distance seems too large. Please check your input';
    }
    
    return null;
  }

  // Heart rate validation
  static String? heartRate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final hrValidation = positiveNumber(value, fieldName: 'Heart rate');
    if (hrValidation != null) return hrValidation;
    
    final heartRate = int.parse(value);
    if (heartRate < 30 || heartRate > 250) {
      return 'Please enter a realistic heart rate (30-250 bpm)';
    }
    
    return null;
  }

  // Blood pressure validation
  static String? bloodPressure(String? value, {required bool isSystolic}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final bpValidation = positiveNumber(value, fieldName: 'Blood pressure');
    if (bpValidation != null) return bpValidation;
    
    final bp = int.parse(value);
    
    if (isSystolic) {
      if (bp < 70 || bp > 250) {
        return 'Systolic pressure should be between 70-250 mmHg';
      }
    } else {
      if (bp < 40 || bp > 150) {
        return 'Diastolic pressure should be between 40-150 mmHg';
      }
    }
    
    return null;
  }

  // Scale rating validation (1-10)
  static String? scaleRating(String? value, {String fieldName = 'Rating'}) {
    final ratingValidation = positiveNumber(value, fieldName: fieldName);
    if (ratingValidation != null) return ratingValidation;
    
    final rating = int.parse(value!);
    if (rating < 1 || rating > 10) {
      return '$fieldName must be between 1 and 10';
    }
    
    return null;
  }

  // Water intake validation (ml)
  static String? waterIntake(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final waterValidation = positiveNumber(value, fieldName: 'Water intake');
    if (waterValidation != null) return waterValidation;
    
    final water = int.parse(value);
    if (water > 10000) {
      return 'Water intake seems too high. Please check your input';
    }
    
    return null;
  }

  // Notes validation
  static String? notes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.length > 500) {
      return 'Notes must be less than 500 characters';
    }
    
    return null;
  }

  // Combined validation function
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

// Date and time utility functions for validation
class DateTimeValidators {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }
  
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

// Number formatting utilities
class NumberFormatters {
  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }
  
  static String formatHeight(double height) {
    return '${height.toStringAsFixed(0)} cm';
  }
  
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(2)} km';
  }
  
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
  
  static String formatCalories(int calories) {
    return '$calories cal';
  }
  
  static String formatHeartRate(int heartRate) {
    return '$heartRate bpm';
  }
  
  static String formatBloodPressure(int systolic, int diastolic) {
    return '$systolic/$diastolic mmHg';
  }
}