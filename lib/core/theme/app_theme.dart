import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.cream500,

      surface: AppColors.surface,

      error: AppColors.error,

      onPrimary: Colors.white,

      onSurface: AppColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
    ),

    dividerColor: AppColors.neutral200,
  );
}