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
      surface: Color(0xFFF8FAFC),
      onSurface: AppColors.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF2F6FB),
      textTheme:
          const TextTheme(
            displayLarge: TextStyle(fontSize: 46, fontWeight: FontWeight.w700),
            displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
            displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ).apply(
            bodyColor: AppColors.onBackground,
            displayColor: AppColors.onBackground,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: const Color(0xFFD1D5DB),
          disabledForegroundColor: const Color(0xFF6B7280),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 46),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6DFEA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6DFEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD6DFEA), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
