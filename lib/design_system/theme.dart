import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class SelfCoachTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: SelfCoachColors.primary,
        primaryContainer: SelfCoachColors.primaryLight,
        secondary: SelfCoachColors.secondary,
        secondaryContainer: SelfCoachColors.secondaryLight,
        tertiary: SelfCoachColors.accent,
        tertiaryContainer: SelfCoachColors.accentYellow,
        error: SelfCoachColors.error,
        errorContainer: Color(0xFFFFEBEE),
        surface: SelfCoachColors.surface,
        surfaceContainerHighest: SelfCoachColors.surfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: SelfCoachColors.textPrimary,
        outline: SelfCoachColors.borderMedium,
        outlineVariant: SelfCoachColors.borderLight,
        shadow: SelfCoachColors.shadowMedium,
      ),
      
      // App Bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: SelfCoachColors.surface,
        foregroundColor: SelfCoachColors.textPrimary,
        elevation: 0,
        shadowColor: SelfCoachColors.shadowLight,
        surfaceTintColor: SelfCoachColors.surface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: SelfCoachColors.textPrimary,
          size: 24,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: SelfCoachColors.surface,
        elevation: 2,
        shadowColor: SelfCoachColors.shadowLight,
        surfaceTintColor: SelfCoachColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelfCoachColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: SelfCoachColors.shadowMedium,
          surfaceTintColor: SelfCoachColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelfCoachColors.primary,
          side: const BorderSide(
            color: SelfCoachColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SelfCoachColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SelfCoachColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SelfCoachColors.borderLight,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SelfCoachColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SelfCoachColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SelfCoachColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: SelfCoachColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          color: SelfCoachColors.textSecondary,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: SelfCoachColors.textTertiary,
          fontSize: 16,
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SelfCoachColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SelfCoachColors.surface,
        selectedItemColor: SelfCoachColors.primary,
        unselectedItemColor: SelfCoachColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: SelfCoachColors.surfaceVariant,
        selectedColor: SelfCoachColors.primary,
        secondarySelectedColor: SelfCoachColors.primaryLight,
        disabledColor: SelfCoachColors.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: const TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 14,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SelfCoachColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SelfCoachColors.primary,
        linearTrackColor: SelfCoachColors.surfaceVariant,
        circularTrackColor: SelfCoachColors.surfaceVariant,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SelfCoachColors.primary;
          }
          return SelfCoachColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SelfCoachColors.primaryLight;
          }
          return SelfCoachColors.surfaceVariant;
        }),
      ),
      
      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: SelfCoachColors.primary,
        inactiveTrackColor: SelfCoachColors.surfaceVariant,
        thumbColor: SelfCoachColors.primary,
        overlayColor: SelfCoachColors.primaryLight,
        valueIndicatorColor: SelfCoachColors.primary,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: SelfCoachColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: SelfCoachColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: SelfCoachColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: SelfCoachColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: SelfCoachColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      
      // Material 3 settings
      useMaterial3: true,
      
      // Platform brightness
      brightness: Brightness.light,
      
      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}