import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/reminder_item.dart';

/// บันทึก/โหลดรายการ ReminderItem ลงเครื่องด้วย shared_preferences
class LocalReminderStorage {
  static const String _storageKey = 'duemate_reminders_v1';

  /// บันทึกรายการทั้งหมดเป็น JSON string เดียว
  Future<void> saveReminders(List<ReminderItem> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((item) => item.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// โหลดรายการจากเครื่อง — คืน [] ถ้าไม่มีข้อมูลหรือ parse ไม่ได้
  Future<List<ReminderItem>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((entry) => ReminderItem.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (_) {
      // JSON เสียหรือรูปแบบไม่ตรง — ไม่ให้แอป crash
      return [];
    }
  }

  /// ล้างข้อมูลรายการที่เก็บไว้
  Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
