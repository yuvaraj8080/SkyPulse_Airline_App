import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Inspired by Flighty
  static const Color primary = Color(0xFF3E78B2);        // Main brand color
  static const Color secondary = Color(0xFF5A9BE6);      // Secondary brand color
  static const Color accent = Color(0xFFFF9671);         // Accent color for highlights
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);        // Green for success states
  static const Color warning = Color(0xFFFFB74D);        // Amber for warnings
  static const Color error = Color(0xFFE57373);          // Red for errors
  static const Color info = Color(0xFF64B5F6);           // Blue for information
  
  // Flight Status Colors
  static const Color onTime = Color(0xFF4CAF50);         // Green for on-time flights
  static const Color delayed = Color(0xFFFFC107);        // Amber for delayed flights
  static const Color cancelled = Color(0xFFF44336);      // Red for cancelled flights
  static const Color landed = Color(0xFF3F51B5);         // Indigo for landed flights
  static const Color boarding = Color(0xFF9C27B0);       // Purple for boarding
  static const Color scheduled = Color(0xFF607D8B);      // Blue-grey for scheduled
  
  // Light Theme
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF6B7A90);
  static const Color lightDivider = Color(0xFFEAECF0);
  
  // Dark Theme
  static const Color darkBackground = Color(0xFF1A1F2B);
  static const Color darkSurface = Color(0xFF2A2F3C);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFADBBCC);
  static const Color darkDivider = Color(0xFF3A3F4C);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Map Colors
  static const Color mapBackground = Color(0xFFE8ECEF);
  static const Color flightPath = primary;
  static const Color flightPathComplete = Color(0xFF90A4AE);
  
  // Subscription Colors
  static const Color freeSubscription = Color(0xFF90A4AE);
  static const Color premiumSubscription = Color(0xFFFFD54F);
  static const Color proSubscription = Color(0xFF7986CB);
}
