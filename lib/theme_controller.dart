import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controller to manage theme mode with persistence using SharedPreferences
class ThemeController extends ChangeNotifier {
  static const _key = 'themeMode'; // 0 system, 1 light, 2 dark
  // Default to system theme mode
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  // Load the saved theme mode from SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_key) ?? 0;
    _mode = ThemeMode.values[v];
    notifyListeners();
  }
  // Set a new theme mode and save it to SharedPreferences
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
    notifyListeners();
  }
}
