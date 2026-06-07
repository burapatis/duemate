import 'package:duemate/services/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('hasAcceptedTerms คืน false เมื่อยังไม่ยืนยัน', () async {
    final prefs = AppPreferences();
    expect(await prefs.hasAcceptedTerms(), false);
  });

  test('setAcceptedTerms บันทึกและอ่านค่าได้', () async {
    final prefs = AppPreferences();
    await prefs.setAcceptedTerms(true);
    expect(await prefs.hasAcceptedTerms(), true);
  });

  test('hasCompletedUsageGuide คืน false เมื่อยังไม่ดูคู่มือ', () async {
    final prefs = AppPreferences();
    expect(await prefs.hasCompletedUsageGuide(), false);
  });

  test('setCompletedUsageGuide บันทึกและอ่านค่าได้', () async {
    final prefs = AppPreferences();
    await prefs.setCompletedUsageGuide(true);
    expect(await prefs.hasCompletedUsageGuide(), true);
  });
}
