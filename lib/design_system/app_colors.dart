import 'package:flutter/material.dart';

/// World-class design system for SelfCoach wellness app
/// Inspired by nature, mindfulness, and modern health aesthetics
class AppColors {
  // Primary palette - Calming Blues (Trust & Reliability - inspired by Apple Health)
  static const Color primary = Color(0xFF2196F3);      // Trust blue
  static const Color primaryLight = Color(0xFF64B5F6);  // Light sky blue  
  static const Color primaryDark = Color(0xFF1976D2);   // Deep ocean blue
  static const Color primaryContainer = Color(0xFFE3F2FD); // Cloud blue
  
  // Secondary palette - Healing Greens (Growth & Wellness - inspired by Headspace)
  static const Color secondary = Color(0xFF4CAF50);     // Healing green
  static const Color secondaryLight = Color(0xFF81C784); // Fresh green
  static const Color secondaryDark = Color(0xFF388E3C);  // Deep forest
  static const Color secondaryContainer = Color(0xFFE8F5E9); // Mint whisper
  
  // Tertiary palette - Energizing Accent (Action & Motivation - inspired by Calm)
  static const Color tertiary = Color(0xFFFF9800);      // Energizing orange
  static const Color tertiaryLight = Color(0xFFFFB74D); // Warm amber
  static const Color tertiaryDark = Color(0xFFF57C00);  // Deep orange
  static const Color tertiaryContainer = Color(0xFFFFF3E0); // Warm cream
  
  // Semantic colors - Gentle and reassuring
  static const Color success = Color(0xFF4CAF68);       // Fresh green
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color warning = Color(0xFFFFB74D);       // Warm amber
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFEF5350);         // Soft coral
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF42A5F5);          // Clear sky
  static const Color infoContainer = Color(0xFFE3F2FD);
  
  // Modern neutral palette - Clean and airy
  static const Color surface = Color(0xFFFAFBFB);       // Soft white
  static const Color surfaceVariant = Color(0xFFF5F8F7); // Mint whisper
  static const Color background = Color(0xFFFFFFFF);    // Pure white
  static const Color backgroundSecondary = Color(0xFFF8FBF9); // Gentle mint
  static const Color onSurface = Color(0xFF1A2E29);     // Forest text
  static const Color onSurfaceVariant = Color(0xFF4A5B56); // Sage text
  static const Color onBackground = Color(0xFF1A2E29);  // Primary text
  static const Color outline = Color(0xFFCDD7D4);       // Soft border
  static const Color outlineVariant = Color(0xFFE8F1EF); // Whisper border
  static const Color shadow = Color(0x0F000000);        // Gentle shadow
  static const Color shadowMedium = Color(0x1A000000);  // Medium shadow
  static const Color shadowStrong = Color(0x26000000);  // Strong shadow
  
  // Wellness activity colors - Harmonious and inspiring
  static const Color meditation = Color(0xFFAB47BC);    // Mindful lavender
  static const Color breathing = Color(0xFF29B6F6);     // Breath sky blue
  static const Color workout = Color(0xFFFF8A65);       // Energy coral
  static const Color stretching = Color(0xFF7986CB);    // Gentle indigo
  static const Color mindfulness = Color(0xFF66BB6A);   // Present green
  static const Color relaxation = Color(0xFF78909C);    // Calm slate
  static const Color yoga = Color(0xFFEC407A);          // Peaceful rose
  static const Color sleep = Color(0xFF9575CD);         // Dream purple
  static const Color hydration = Color(0xFF26C6DA);     // Water aqua
  static const Color nutrition = Color(0xFF8BC34A);     // Nourish lime
  
  // Health metrics colors - Clear and motivating
  static const Color steps = Color(0xFF66BB6A);         // Movement green
  static const Color heartRate = Color(0xFFEF5350);     // Heart coral
  static const Color sleepMetrics = Color(0xFF9575CD);  // Rest purple
  static const Color nutritionMetrics = Color(0xFF8BC34A); // Health lime
  static const Color weight = Color(0xFFAB47BC);        // Balance purple
  static const Color bloodPressure = Color(0xFFEC407A); // Vitality rose
  static const Color energy = Color(0xFFFFA726);        // Vitality amber
  static const Color mood = Color(0xFF42A5F5);          // Joy blue
  
  // Beautiful gradients for modern wellness design
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF68),
    Color(0xFF2E7D5A),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF7BBFBB),
    Color(0xFF5BA3A0),
  ];
  
  static const List<Color> tertiaryGradient = [
    Color(0xFF98D4E0),
    Color(0xFF79C3D1),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFFAFBFB),
    Color(0xFFF8FBF9),
    Color(0xFFFFFFFF),
  ];
  
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFAFBFB),
  ];
  
  static const List<Color> sunriseGradient = [
    Color(0xFFFFE0B2),
    Color(0xFFFFCC80),
    Color(0xFFFFB74D),
  ];
  
  static const List<Color> oceansGradient = [
    Color(0xFF81C784),
    Color(0xFF4FC3F7),
    Color(0xFF29B6F6),
  ];
  
  static const List<Color> forestGradient = [
    Color(0xFF66BB6A),
    Color(0xFF4CAF68),
    Color(0xFF2E7D5A),
  ];
  
  static const List<Color> twilightGradient = [
    Color(0xFF9575CD),
    Color(0xFFAB47BC),
    Color(0xFF7986CB),
  ];
  
  // Dark mode colors (for future dark theme support)
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkPrimary = Color(0xFF66BB6A);
  
  // Utility methods
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  static LinearGradient createGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }
  
  // Comprehensive color mapping for wellness activities
  static Map<String, Color> getWellnessTypeColors() {
    return {
      'meditation': meditation,
      'breathing': breathing,
      'workout': workout,
      'stretching': stretching,
      'mindfulness': mindfulness,
      'relaxation': relaxation,
      'yoga': yoga,
      'sleep': sleep,
      'hydration': hydration,
      'nutrition': nutrition,
      'steps': steps,
      'heartRate': heartRate,
      'energy': energy,
      'mood': mood,
    };
  }
  
  // Get gradient for wellness type
  static LinearGradient getWellnessGradient(String type) {
    switch (type.toLowerCase()) {
      case 'sleep':
      case 'meditation':
        return createGradient(colors: twilightGradient);
      case 'hydration':
      case 'breathing':
        return createGradient(colors: oceansGradient);
      case 'nutrition':
      case 'workout':
        return createGradient(colors: forestGradient);
      case 'energy':
      case 'mood':
        return createGradient(colors: sunriseGradient);
      default:
        return createGradient(colors: primaryGradient);
    }
  }
  
  // Create modern card shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: shadowMedium,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Create subtle card shadow
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  // Create strong elevation shadow
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: shadowStrong,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Wellness gradient for general use
  static const List<Color> wellnessGradient = [
    Color(0xFF66BB6A),
    Color(0xFF4CAF68),
    Color(0xFF2E7D5A),
  ];
}