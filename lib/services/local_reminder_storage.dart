import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/reminder_item.dart';

/// ผลการโหลดรายการจากเครื่อง — แยกรายการที่โหลดได้กับจำนวนที่ข้าม
class ReminderLoadResult {
  const ReminderLoadResult({
    required this.items,
    this.skippedCount = 0,
  });

  final List<ReminderItem> items;

  /// จำนวนรายการที่ parse ไม่ได้ (รูปแบบไม่ตรงหรือ field เสีย)
  final int skippedCount;
}

/// บันทึก/โหลดรายการ ReminderItem ลงเครื่องด้วย shared_preferences
class LocalReminderStorage {
  static const String _storageKey = 'duemate_reminders_v1';

  /// บันทึกรายการทั้งหมดเป็น JSON string เดียว
  Future<void> saveReminders(List<ReminderItem> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((item) => item.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// โหลดรายการจากเครื่อง — parse ทีละรายการ ข้ามรายการที่เสีย
  Future<ReminderLoadResult> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return const ReminderLoadResult(items: []);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const ReminderLoadResult(items: []);
      }

      final items = <ReminderItem>[];
      var skippedCount = 0;

      for (final entry in decoded) {
        if (entry is! Map) {
          skippedCount++;
          continue;
        }

        try {
          items.add(
            ReminderItem.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (error, stackTrace) {
          skippedCount++;
          // บันทึกใน debug เพื่อช่วยตรวจสอบ ไม่แสดงให้ผู้ใช้
          debugPrint(
            'DueMate: ข้ามรายการที่โหลดไม่ได้ — $error\n$stackTrace',
          );
        }
      }

      return ReminderLoadResult(
        items: items,
        skippedCount: skippedCount,
      );
    } catch (_) {
      // JSON ทั้งก้อนเสีย — ไม่ให้แอป crash
      return const ReminderLoadResult(items: []);
    }
  }

  /// ล้างข้อมูลรายการที่เก็บไว้
  Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
