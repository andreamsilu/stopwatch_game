import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

const swahiliLocale = Locale('sw');
const englishLocale = Locale('en');

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>(
  (ref) => AppLocaleNotifier(),
);

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier() : super(swahiliLocale) {
    _restore();
  }

  static const _preferenceKey = 'app_language';

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    final restored = preferences.getString(_preferenceKey) == 'en'
        ? englishLocale
        : swahiliLocale;
    AppLanguage.code = restored.languageCode;
    state = restored;
  }

  Future<void> select(Locale locale) async {
    if (locale.languageCode != 'sw' && locale.languageCode != 'en') return;
    final selected = locale.languageCode == 'en'
        ? englishLocale
        : swahiliLocale;
    AppLanguage.code = selected.languageCode;
    state = selected;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, state.languageCode);
  }
}
