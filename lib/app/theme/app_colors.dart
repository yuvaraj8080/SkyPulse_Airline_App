import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Dark Theme with Blue Accents
  static const Color primary =
      Color(0xFF2196F3); // Main brand color - Vibrant Blue
  static const Color secondary =
      Color(0xFF42A5F5); // Secondary brand color - Lighter Blue
  static const Color accent = Color(0xFF64B5F6); // Accent color for highlights

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green for success states
  static const Color warning = Color(0xFFFFB74D); // Amber for warnings
  static const Color error = Color(0xFFE57373); // Red for errors
  static const Color info = Color(0xFF64B5F6); // Blue for information

  // Flight Status Colors
  static const Color onTime = Color(0xFF4CAF50); // Green for on-time flights
  static const Color delayed = Color(0xFFFFB74D); // Amber for delayed flights
  static const Color cancelled = Color(0xFFE57373); // Red for cancelled flights
  static const Color landed = Color(0xFF3F51B5); // Indigo for landed flights
  static const Color boarding = Color(0xFF9C27B0); // Purple for boarding
  static const Color scheduled = Color(0xFF607D8B); // Blue-grey for scheduled

  // Dark Theme Colors
  static const Color darkBackground =
      Color(0xFF0F172A); // Very dark blue/black background
  static const Color darkSurface = Color(0xFF1E293B); // Dark surface for cards
  static const Color darkCard =
      Color(0xFF2D3748); // Dark grey for cards and input fields
  static const Color darkText = Color(0xFFFFFFFF); // White text
  static const Color darkTextSecondary =
      Color(0xFFB0BEC5); // Light grey for secondary text
  static const Color darkDivider = Color(0xFF374151); // Dark divider

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF6B7A90);
  static const Color lightDivider = Color(0xFFEAECF0);

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
  static const Color mapBackground = Color(0xFF1A202C);
  static const Color flightPath = primary;
  static const Color flightPathComplete = Color(0xFF90A4AE);

  // Subscription Colors
  static const Color freeSubscription = Color(0xFF90A4AE);
  static const Color premiumSubscription = Color(0xFFFFD54F);
  static const Color proSubscription = Color(0xFF7986CB);

  // UI Specific Colors
  static const Color bottomNavBar =
      Color(0xFF1E293B); // Dark grey for bottom navigation
  static const Color inputBackground =
      Color(0xFF374151); // Input field background
  static const Color iconColor = Color(0xFFFFFFFF); // White icons
  static const Color iconInactive = Color(0xFF6B7280); // Inactive icon color
}
