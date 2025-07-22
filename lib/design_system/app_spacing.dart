/// Consistent spacing system for the SelfCoach app
/// Following 8pt grid system for better visual rhythm
class AppSpacing {
  // Base spacing units (8pt grid system)
  static const double xs = 4.0;    // Extra small
  static const double sm = 8.0;    // Small
  static const double md = 16.0;   // Medium (base unit)
  static const double lg = 24.0;   // Large
  static const double xl = 32.0;   // Extra large
  static const double xxl = 48.0;  // Double extra large
  static const double xxxl = 64.0; // Triple extra large
  
  // Specific use-case spacing
  static const double cardPadding = md;           // 16px
  static const double screenPadding = md;         // 16px
  static const double buttonPadding = sm;         // 8px
  static const double listItemSpacing = sm;       // 8px
  static const double sectionSpacing = lg;        // 24px
  static const double elementSpacing = sm;        // 8px
  static const double iconSpacing = xs;           // 4px
  static const double formFieldSpacing = md;      // 16px
  
  // Component-specific spacing
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double fabSize = 56.0;
  static const double avatarSize = 40.0;
  static const double iconButtonSize = 48.0;
  
  // Layout spacing
  static const double maxContentWidth = 400.0;   // Max width for forms/content
  static const double minTouchTarget = 44.0;     // Minimum touch target size
  
  // Border radius system
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;       // Fully rounded
  
  // Elevation system (for shadows and z-index)
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
}