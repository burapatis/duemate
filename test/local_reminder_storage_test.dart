import 'package:duemate/features/home/reminder_item.dart';
import 'package:duemate/services/local_reminder_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReminderItem _sampleItem({required String id, required String title}) {
  return ReminderItem(
    id: id,
    title: title,
    category: 'รถ',
    dueDate: DateTime(2026, 6, 15),
    reminderDays: [30, 7],
    note: 'ทดสอบ',
    priority: 'สูง',
  );
}

void main() {
  late LocalReminderStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = LocalReminderStorage();
  });

  test('saveReminders และ loadReminders คืนรายการเดิมได้', () async {
    final items = [
      _sampleItem(id: 'save-001', title: 'พ.ร.บ. รถยนต์'),
      _sampleItem(id: 'save-002', title: 'ใบขับขี่'),
    ];

    await storage.saveReminders(items);
    final loaded = await storage.loadReminders();

    expect(loaded.length, 2);
    expect(loaded[0].id, 'save-001');
    expect(loaded[1].title, 'ใบขับขี่');
  });

  test('loadReminders คืน [] เมื่อยังไม่มีข้อมูล', () async {
    final loaded = await storage.loadReminders();
    expect(loaded, isEmpty);
  });

  test('loadReminders คืน [] เมื่อ JSON เสีย', () async {
    SharedPreferences.setMockInitialValues({
      'duemate_reminders_v1': '{not-valid-json',
    });

    final loaded = await storage.loadReminders();
    expect(loaded, isEmpty);
  });

  test('clearReminders ล้างข้อมูลแล้ว load ได้ []', () async {
    await storage.saveReminders([
      _sampleItem(id: 'clear-001', title: 'ทดสอบลบ'),
    ]);

    await storage.clearReminders();
    final loaded = await storage.loadReminders();

    expect(loaded, isEmpty);
  });
}
