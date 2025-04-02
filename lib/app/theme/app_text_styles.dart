import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle headline1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.5,
  );
  
  static final TextStyle headline2 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static final TextStyle headline3 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static final TextStyle headline4 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );
  
  static final TextStyle headline5 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  
  static final TextStyle headline6 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static final TextStyle subtitle1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static final TextStyle subtitle2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static final TextStyle bodyText1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );
  
  static final TextStyle bodyText2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
  
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
  
  static final TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  );
  
  // Flight specific text styles
  static final TextStyle flightNumber = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );
  
  static final TextStyle flightTime = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
  
  static final TextStyle airportCode = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );
  
  static final TextStyle airportName = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
  
  static final TextStyle flightStatus = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );
  
  static final TextStyle flightInfo = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
  
  static final TextStyle subscriptionTitle = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
  
  static final TextStyle subscriptionPrice = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static final TextStyle subscriptionFeature = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  // Tab and navigation text styles
  static final TextStyle tabLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
  );
  
  static final TextStyle bottomNavLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
