import 'package:flutter/material.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_mode';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeProvider() {
    _load();
  }

  ThemeMode get themeMode => _mode;
  ThemeData get lightTheme => appLightTheme;
  ThemeData get darkTheme => appDarkTheme;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isLight => _mode == ThemeMode.light;
  bool get isSystem => _mode == ThemeMode.system;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  Future<void> setLight() => setMode(ThemeMode.light);
  Future<void> setDark() => setMode(ThemeMode.dark);
  Future<void> setSystem() => setMode(ThemeMode.system);

  Future<void> toggle() {
    return setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
