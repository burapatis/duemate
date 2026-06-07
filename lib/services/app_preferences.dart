import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// การตั้งค่าแอปที่เก็บในเครื่อง — เช่น โหมดธีม และขั้นตอนแรกเข้าใช้งาน
class AppPreferences {
  static const _themeModeKey = 'duemate_theme_mode';
  static const _acceptedTermsKey = 'duemate_accepted_terms';
  static const _completedUsageGuideKey = 'duemate_completed_usage_guide';

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acceptedTermsKey) ?? false;
  }

  Future<void> setAcceptedTerms(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedTermsKey, value);
  }

  Future<bool> hasCompletedUsageGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedUsageGuideKey) ?? false;
  }

  Future<void> setCompletedUsageGuide(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedUsageGuideKey, value);
  }
}
