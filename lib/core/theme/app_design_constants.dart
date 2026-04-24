import 'package:flutter/material.dart';

class AppDesignConstants {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusCircular = 100.0;

  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusExtraLarge => BorderRadius.circular(radiusExtraLarge);
  static BorderRadius get borderRadiusCircular => BorderRadius.circular(radiusCircular);

  // Paddings & Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const EdgeInsets edgeInsetsSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets edgeInsetsMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets edgeInsetsLarge = EdgeInsets.all(paddingLarge);

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}
