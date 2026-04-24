import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Roboto'; // Default or custom font

  static const TextTheme textTheme = TextTheme(
    // Large Titles (e.g., Login/Signup Title)
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      letterSpacing: 1.2,
    ),
    
    // Page Titles (e.g., AppBar Title)
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    
    // Section Headers / Card Titles
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    // Standard Body Text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),

    // Subtitles / Secondary Body Text
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),

    // Small captions or hints
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textGrey,
    ),

    // Button Text
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );
}
