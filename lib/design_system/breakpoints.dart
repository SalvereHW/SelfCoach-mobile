import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width <= 360;
  }
  
  static bool isShortScreen(BuildContext context) {
    return MediaQuery.of(context).size.height <= 700;
  }
}

/// Responsive spacing system
class ResponsiveSpacing {
  static double getSpacing(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    if (Breakpoints.isMobile(context)) return mobile;
    if (Breakpoints.isTablet(context)) return tablet;
    return desktop;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 12.0;
    if (Breakpoints.isMobile(context)) return 16.0;
    if (Breakpoints.isTablet(context)) return 24.0;
    return 32.0;
  }
  
  static double getVerticalPadding(BuildContext context) {
    if (Breakpoints.isShortScreen(context)) return 8.0;
    if (Breakpoints.isMobile(context)) return 16.0;
    if (Breakpoints.isTablet(context)) return 24.0;
    return 32.0;
  }
  
  static double getCardSpacing(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 8.0;
    if (Breakpoints.isMobile(context)) return 12.0;
    if (Breakpoints.isTablet(context)) return 16.0;
    return 20.0;
  }
}

/// Responsive text sizes
class ResponsiveText {
  static double getHeadlineSize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 20.0;
    if (Breakpoints.isMobile(context)) return 24.0;
    if (Breakpoints.isTablet(context)) return 28.0;
    return 32.0;
  }
  
  static double getTitleSize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 16.0;
    if (Breakpoints.isMobile(context)) return 18.0;
    if (Breakpoints.isTablet(context)) return 20.0;
    return 22.0;
  }
  
  static double getBodySize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 14.0;
    if (Breakpoints.isMobile(context)) return 16.0;
    if (Breakpoints.isTablet(context)) return 16.0;
    return 18.0;
  }
  
  static double getCaptionSize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 12.0;
    if (Breakpoints.isMobile(context)) return 14.0;
    if (Breakpoints.isTablet(context)) return 14.0;
    return 16.0;
  }
}

/// Responsive icon sizes
class ResponsiveIcon {
  static double getSize(BuildContext context, {
    double mobile = 24.0,
    double tablet = 28.0,
    double desktop = 32.0,
  }) {
    if (Breakpoints.isMobile(context)) return mobile;
    if (Breakpoints.isTablet(context)) return tablet;
    return desktop;
  }
  
  static double getSmallSize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 16.0;
    if (Breakpoints.isMobile(context)) return 20.0;
    if (Breakpoints.isTablet(context)) return 24.0;
    return 28.0;
  }
  
  static double getLargeSize(BuildContext context) {
    if (Breakpoints.isSmallPhone(context)) return 32.0;
    if (Breakpoints.isMobile(context)) return 40.0;
    if (Breakpoints.isTablet(context)) return 48.0;
    return 56.0;
  }
}