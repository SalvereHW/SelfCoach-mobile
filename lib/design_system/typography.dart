import 'package:flutter/material.dart';
import 'app_colors.dart';

/// World-class typography system for SelfCoach wellness app
/// Optimized for readability, accessibility, and modern aesthetics
class AppTypography {
  // Font families
  static const String primaryFont = 'SF Pro Display'; // iOS system font
  static const String secondaryFont = 'SF Pro Text';  // iOS system font
  static const String displayFont = 'SF Pro Display'; // For headers
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  // Display styles - For hero sections and major headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 56,
    fontWeight: extraBold,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.onBackground,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 44,
    fontWeight: bold,
    height: 1.15,
    letterSpacing: -0.25,
    color: AppColors.onBackground,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  // Headline styles - For section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  // Title styles - For cards and components
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );
  
  // Body styles - For main content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.onBackground,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );
  
  // Label styles - For buttons and small text
  static const TextStyle labelLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: medium,
    height: 1.35,
    letterSpacing: 0.5,
    color: AppColors.onBackground,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 10,
    fontWeight: medium,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );
  
  // Special wellness-focused styles
  static const TextStyle quote = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: light,
    height: 1.6,
    letterSpacing: 0.15,
    fontStyle: FontStyle.italic,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle metric = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    fontWeight: extraBold,
    height: 1.0,
    letterSpacing: -1.0,
    color: AppColors.primary,
  );
  
  static const TextStyle metricLabel = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: medium,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // Utility methods for common text modifications
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }
  
  // Create text theme for Flutter ThemeData
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

/// Spacing system for consistent layouts
class AppSpacing {
  static const double xs = 4.0;   // Extra small
  static const double sm = 8.0;   // Small
  static const double md = 16.0;  // Medium (base)
  static const double lg = 24.0;  // Large
  static const double xl = 32.0;  // Extra large
  static const double xxl = 48.0; // Extra extra large
  static const double xxxl = 64.0; // Triple extra large
  
  // Semantic spacing
  static const double cardPadding = md;
  static const double screenPadding = lg;
  static const double sectionSpacing = xl;
  static const double componentSpacing = sm;
}

/// Border radius system for consistent rounding
class AppRadius {
  static const double xs = 4.0;   // Extra small
  static const double sm = 8.0;   // Small
  static const double md = 12.0;  // Medium (base)
  static const double lg = 16.0;  // Large
  static const double xl = 20.0;  // Extra large
  static const double xxl = 24.0; // Extra extra large
  static const double round = 50.0; // Fully rounded (for buttons, avatars)
  
  // Semantic border radius
  static const double card = md;
  static const double button = sm;
  static const double input = sm;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
}