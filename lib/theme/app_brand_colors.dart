import 'package:flutter/material.dart';

/// สีและ gradient ตามแนว DOCSAFE — ใช้ร่วมกันทั้งแอป
class AppBrandColors {
  static const gradientStart = Color(0xFF4F7CFF);
  static const gradientEnd = Color(0xFF8B5CF6);
  static const primaryBlue = Color(0xFF4285F4);

  static const summaryOrange = Color(0xFFFF7043);
  static const summaryYellow = Color(0xFFFFCA28);
  static const summaryGreen = Color(0xFF43A047);

  static const badgeOrange = Color(0xFFFF7043);
  static const badgeYellow = Color(0xFFFFB300);
  static const badgeGreen = Color(0xFF43A047);
  static const badgeRed = Color(0xFFE53935);

  static const pageBackground = Color(0xFFF3F5F9);
  static const sheetBackground = Colors.white;

  static const headerGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
