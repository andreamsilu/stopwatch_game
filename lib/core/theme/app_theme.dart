import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      surface: AppColors.background,
      onSurface: AppColors.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme:
          const TextTheme(
            displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
            displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            headlineMedium: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ).apply(
            bodyColor: AppColors.onBackground,
            displayColor: AppColors.onBackground,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: const Color(0xFFD1D5DB),
          disabledForegroundColor: const Color(0xFF6B7280),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 1.4),
        ),
      ),
    );
  }
}
