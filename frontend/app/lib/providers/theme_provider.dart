import "package:flutter/material.dart";

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    if (themeMode == _themeMode) return;
    _themeMode = themeMode;
    notifyListeners();
  }
}