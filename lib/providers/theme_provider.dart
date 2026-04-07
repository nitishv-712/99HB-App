import 'package:flutter/material.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode;

  ThemeProvider({ThemeMode initial = ThemeMode.system}) : _mode = initial;

  ThemeMode get themeMode => _mode;
  ThemeData get currentTheme =>
      _mode == ThemeMode.dark ? appDarkTheme : appLightTheme;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isLight => _mode == ThemeMode.light;
  bool get isSystem => _mode == ThemeMode.system;

  void setLight() {
    if (_mode == ThemeMode.light) return;
    _mode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    if (_mode == ThemeMode.dark) return;
    _mode = ThemeMode.dark;
    notifyListeners();
  }

  void setSystem() {
    if (_mode == ThemeMode.system) return;
    _mode = ThemeMode.system;
    notifyListeners();
  }

  void toggle() {
    _mode = (_mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
