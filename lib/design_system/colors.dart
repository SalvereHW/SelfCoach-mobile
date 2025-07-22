import 'package:flutter/material.dart';

/// SelfCoach Design System Colors
/// Inspired by gamification, wellness, and user engagement
class SelfCoachColors {
  // Primary colors - Fresh and engaging
  static const Color primary = Color(0xFF00C896); // Fresh mint green
  static const Color primaryDark = Color(0xFF00A378); // Darker mint
  static const Color primaryLight = Color(0xFF4DFFB8); // Light mint
  
  // Secondary colors - Motivating and energetic
  static const Color secondary = Color(0xFF6C5CE7); // Vibrant purple
  static const Color secondaryDark = Color(0xFF5A4FCF); // Darker purple
  static const Color secondaryLight = Color(0xFF8B7EE8); // Light purple
  
  // Accent colors - For highlights and achievements
  static const Color accent = Color(0xFFFF6B6B); // Coral red
  static const Color accentYellow = Color(0xFFFFD93D); // Bright yellow
  static const Color accentOrange = Color(0xFFFF9F43); // Orange
  static const Color accentBlue = Color(0xFF4ECDC4); // Turquoise
  
  // Neutral colors - Clean and modern
  static const Color background = Color(0xFFF8FAFC); // Very light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light gray
  
  // Text colors - High contrast and readable
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Medium slate
  static const Color textTertiary = Color(0xFF94A3B8); // Light slate
  
  // Semantic colors - For feedback and status
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Health-specific colors
  static const Color sleep = Color(0xFF8B5CF6); // Purple
  static const Color nutrition = Color(0xFF06B6D4); // Cyan
  static const Color activity = Color(0xFF84CC16); // Lime
  static const Color wellness = Color(0xFFEC4899); // Pink
  
  // Gamification colors
  static const Color achievement = Color(0xFFFFD700); // Gold
  static const Color streak = Color(0xFFFF6B35); // Orange-red
  static const Color level = Color(0xFF9333EA); // Purple
  static const Color reward = Color(0xFF06B6D4); // Cyan
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentOrange],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );
  
  // Shadow colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  
  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);
}