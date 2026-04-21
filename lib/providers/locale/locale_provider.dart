import 'dart:ui';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale> {
  // جعل اللغة العربية هي اللغة الافتراضية عند بدء التشغيل لأول مرة
  LocaleNotifier() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  static const String _prefKey = 'app_locale';
  static const String _enCode = 'en';
  static const String _arCode = 'ar';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    if (savedCode != null && (savedCode == _enCode || savedCode == _arCode)) {
      state = Locale(savedCode);
    } else {
      // إذا لم يكن هناك لغة محفوظة، نثبت العربية كافتراضية
      state = const Locale(_arCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final next = state.languageCode == _arCode
        ? const Locale(_enCode)
        : const Locale(_arCode);
    await setLocale(next);
  }

  Future<void> clearLocale() async {
    // العودة للافتراضي (العربية) بدلاً من null
    state = const Locale(_arCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
