import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
      onBackground: AppColors.lightText,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.headline6.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightSurface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.lightText),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.lightText),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.lightText),
      headlineMedium: AppTextStyles.headline4.copyWith(color: AppColors.lightText),
      headlineSmall: AppTextStyles.headline5.copyWith(color: AppColors.lightText),
      titleLarge: AppTextStyles.headline6.copyWith(color: AppColors.lightText),
      titleMedium: AppTextStyles.subtitle1.copyWith(color: AppColors.lightText),
      titleSmall: AppTextStyles.subtitle2.copyWith(color: AppColors.lightText),
      bodyLarge: AppTextStyles.bodyText1.copyWith(color: AppColors.lightText),
      bodyMedium: AppTextStyles.bodyText2.copyWith(color: AppColors.lightText),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.lightText),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.lightTextSecondary),
      labelSmall: AppTextStyles.overline.copyWith(color: AppColors.lightTextSecondary),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.lightTextSecondary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: AppTextStyles.tabLabel,
      unselectedLabelStyle: AppTextStyles.tabLabel,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSecondary,
      selectedLabelStyle: AppTextStyles.bottomNavLabel,
      unselectedLabelStyle: AppTextStyles.bottomNavLabel,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      disabledColor: AppColors.lightDivider,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.lightText),
      secondaryLabelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
      brightness: Brightness.light,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
      onBackground: AppColors.darkText,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: AppColors.darkSurface,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.headline6.copyWith(color: AppColors.darkText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkSurface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.darkText),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.darkText),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.darkText),
      headlineMedium: AppTextStyles.headline4.copyWith(color: AppColors.darkText),
      headlineSmall: AppTextStyles.headline5.copyWith(color: AppColors.darkText),
      titleLarge: AppTextStyles.headline6.copyWith(color: AppColors.darkText),
      titleMedium: AppTextStyles.subtitle1.copyWith(color: AppColors.darkText),
      titleSmall: AppTextStyles.subtitle2.copyWith(color: AppColors.darkText),
      bodyLarge: AppTextStyles.bodyText1.copyWith(color: AppColors.darkText),
      bodyMedium: AppTextStyles.bodyText2.copyWith(color: AppColors.darkText),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.darkText),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.darkTextSecondary),
      labelSmall: AppTextStyles.overline.copyWith(color: AppColors.darkTextSecondary),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTextStyles.button,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.darkTextSecondary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: AppTextStyles.tabLabel,
      unselectedLabelStyle: AppTextStyles.tabLabel,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkTextSecondary,
      selectedLabelStyle: AppTextStyles.bottomNavLabel,
      unselectedLabelStyle: AppTextStyles.bottomNavLabel,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      disabledColor: AppColors.darkDivider,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.darkText),
      secondaryLabelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
      brightness: Brightness.dark,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
