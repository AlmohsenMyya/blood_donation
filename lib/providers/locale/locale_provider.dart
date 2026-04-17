import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  static const String _prefKey = 'app_locale';
  static const String _enCode = 'en';
  static const String _arCode = 'ar';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    if (savedCode == _enCode || savedCode == _arCode) {
      state = Locale(savedCode!);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final next = state?.languageCode == _arCode
        ? const Locale(_enCode)
        : const Locale(_arCode);
    await setLocale(next);
  }

  Future<void> clearLocale() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
  LocaleNotifier() : super(null);

  void setLocale(Locale locale) => state = locale;

  void clearLocale() => state = null;
}
