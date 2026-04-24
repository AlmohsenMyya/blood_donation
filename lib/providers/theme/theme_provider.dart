import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheryan/core/theme/app_theme.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';

/// Provides the current theme based on the user's role
final themeProvider = Provider<ThemeData>((ref) {
  final role = ref.watch(roleProvider);
  return AppTheme.getTheme(role);
});