import 'package:flutter/material.dart';

/// Controller for managing active [ThemeMode] (light, dark, system).
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.initialMode = ThemeMode.system]);

  /// Sets the explicit [ThemeMode].
  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
    }
  }

  /// Toggles between light and dark mode.
  /// If currently system, checks platform brightness or defaults to dark.
  void toggleTheme([Brightness? platformBrightness]) {
    switch (value) {
      case ThemeMode.light:
        value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        value = ThemeMode.light;
        break;
      case ThemeMode.system:
        final currentBrightness = platformBrightness ?? Brightness.light;
        value = currentBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark;
        break;
    }
  }

  /// Whether current active mode resolves to dark given platform brightness.
  bool isDark(Brightness platformBrightness) {
    switch (value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark;
    }
  }
}
