import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundBlack,
      primaryColor: AppColors.primaryRed,
      
      // Text Theme
      textTheme: AppTypography.textTheme,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.textTheme.titleLarge,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppDesignConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: AppDesignConstants.borderRadiusMedium,
          ),
          elevation: AppDesignConstants.elevationLow,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme (Text fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldDark,
        hintStyle: const TextStyle(color: AppColors.textGrey),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryRed,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.fieldDark,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundBlack,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
