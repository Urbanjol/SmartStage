import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Services/local_storage_service.dart';
import '../Providers/service_providers.dart';


final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return ThemeModeNotifier(localStorage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final _storage;
  static const _themeKey = "user_theme_mode";

  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    // Read cached preference from shared preferences
    final savedTheme = _storage.getUserPhone(); // Using string helper or custom string
    final themeString = _storage.getThemeMode();

    if (themeString == 'dark') state = ThemeMode.dark;
    if (themeString == 'light') state = ThemeMode.light;
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      _storage.cacheThemeMode('dark');
      //_storage._prefs.setString(_themeKey, 'dark');
    } else {
      state = ThemeMode.light;
      _storage.cacheThemeMode('light');
      //_storage._prefs.setString(_themeKey, 'light');
    }
  }
}