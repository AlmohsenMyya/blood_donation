import 'package:sheryan/core/enums/user_role.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// Returns the appropriate theme based on the user role
  static ThemeData getTheme(UserRole? role) {
    switch (role) {
      case UserRole.donor:
        return _buildTheme(
          primary: AppColors.donorPrimary,
          accent: AppColors.donorAccent,
          scaffoldBackground: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          appBarColor: AppColors.donorAccent,
        );
      case UserRole.hospitalAdmin:
        return _buildTheme(
          primary: AppColors.hospitalPrimary,
          accent: AppColors.hospitalAccent,
          scaffoldBackground: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          appBarColor: AppColors.hospitalAccent,
        );
      case UserRole.superAdmin:
        return _buildTheme(
          primary: AppColors.adminPrimary,
          accent: AppColors.adminAccent,
          scaffoldBackground: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          appBarColor: AppColors.adminAccent,
        );
      case UserRole.recipient:
      default:
        return _buildTheme(
          primary: AppColors.recipientPrimary,
          accent: AppColors.recipientAccent,
          scaffoldBackground: AppColors.backgroundBlack,
          surface: AppColors.surfaceDark,
          appBarColor: AppColors.recipientAccent,
        );
    }
  }

  /// Base theme builder to ensure consistency across roles
  static ThemeData _buildTheme({
    required Color primary,
    required Color accent,
    required Color scaffoldBackground,
    required Color surface,
    required Color appBarColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      
      // Text Theme
      textTheme: AppTypography.textTheme,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.textTheme.titleLarge,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppDesignConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: AppDesignConstants.borderRadiusMedium,
          ),
          elevation: AppDesignConstants.elevationLow,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme
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
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesignConstants.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.fieldDark,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldBackground,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Bottom App Bar Theme
      bottomAppBarTheme: BottomAppBarTheme(color: appBarColor),
    );
  }

  // Keep darkTheme for backward compatibility during refactoring if needed
  static ThemeData get darkTheme => getTheme(null);
}