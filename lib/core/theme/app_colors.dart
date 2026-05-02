import 'package:flutter/material.dart';

class AppColors {
  // ─── Pure Medical: Primary (Teal-Blue) ────────────────────────────────────
  static const Color medicalBlue      = Color(0xFF0891B2); // light mode primary
  static const Color medicalBlueDark  = Color(0xFF38BDF8); // dark mode primary
  static const Color medicalBlueLight = Color(0xFFE0F2FE); // primary container light

  // ─── Blood Red (always red — blood-specific actions only) ─────────────────
  static const Color bloodRed         = Color(0xFFDC2626); // light mode
  static const Color bloodRedDark     = Color(0xFFF87171); // dark mode
  static const Color bloodRedLight    = Color(0xFFFEE2E2); // container

  // ─── Light Mode Backgrounds ───────────────────────────────────────────────
  static const Color scaffoldLight        = Color(0xFFFFFFFF);
  static const Color surfaceLight         = Color(0xFFF8FAFC);
  static const Color surfaceContainerLight= Color(0xFFF1F5F9);
  static const Color fieldLight           = Color(0xFFF1F5F9);
  static const Color borderLight          = Color(0xFFE2E8F0);

  // ─── Dark Mode Backgrounds ────────────────────────────────────────────────
  static const Color scaffoldDarkNew         = Color(0xFF0F172A);
  static const Color surfaceDarkNew          = Color(0xFF1E293B);
  static const Color surfaceContainerDarkNew = Color(0xFF1E293B);
  static const Color fieldDarkNew            = Color(0xFF1E293B);
  static const Color borderDark              = Color(0xFF334155);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textOnLight          = Color(0xFF0F172A);
  static const Color textOnLightSecondary = Color(0xFF64748B);
  static const Color textOnDark           = Color(0xFFF8FAFC);
  static const Color textOnDarkSecondary  = Color(0xFF94A3B8);

  // ─── Semantic / Status ────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color error   = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF0891B2);

  // ─── Legacy aliases (backward compatibility — do not remove) ──────────────
  static const Color primaryRed      = bloodRed;
  static const Color accentRed       = Color(0xFFEF4444);
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color backgroundDark  = Color(0xFF0D0D0D);
  static const Color surfaceDark     = Color(0xFF161616);
  static const Color fieldDark       = Color(0xFF2E2E2E);
  static const Color greyCard        = Color(0xFF212121);
  static const Color textPrimary     = Colors.white;
  static const Color textSecondary   = Colors.white70;
  static const Color textGrey        = Colors.grey;

  // ─── Role colors (kept for any remaining references) ──────────────────────
  static const Color donorPrimary    = medicalBlue;
  static const Color donorAccent     = medicalBlue;
  static const Color recipientPrimary= medicalBlue;
  static const Color recipientAccent = medicalBlue;
  static const Color hospitalPrimary = medicalBlue;
  static const Color hospitalAccent  = medicalBlue;
  static const Color adminPrimary    = medicalBlue;
  static const Color adminAccent     = medicalBlue;
}
