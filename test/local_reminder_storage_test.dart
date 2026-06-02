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
    final result = await storage.loadReminders();

    expect(result.items.length, 2);
    expect(result.skippedCount, 0);
    expect(result.items[0].id, 'save-001');
    expect(result.items[1].title, 'ใบขับขี่');
  });

  test('loadReminders คืน [] เมื่อยังไม่มีข้อมูล', () async {
    final result = await storage.loadReminders();
    expect(result.items, isEmpty);
    expect(result.skippedCount, 0);
  });

  test('loadReminders คืน [] เมื่อ JSON ทั้งก้อนเสีย', () async {
    SharedPreferences.setMockInitialValues({
      'duemate_reminders_v1': '{not-valid-json',
    });

    final result = await storage.loadReminders();
    expect(result.items, isEmpty);
    expect(result.skippedCount, 0);
  });

  test('loadReminders ข้ามรายการเสีย แต่คืนรายการที่โหลดได้', () async {
    SharedPreferences.setMockInitialValues({
      'duemate_reminders_v1': '''
[
  {"id":"good-001","title":"พ.ร.บ. รถยนต์","category":"รถ","dueDate":"2026-06-15T00:00:00.000","reminderDays":[30,7],"note":"","priority":"สูง"},
  {"id":"bad-001","title":"เสีย","category":"รถ"},
  {"id":"good-002","title":"ใบขับขี่","category":"รถ","dueDate":"2026-07-01T00:00:00.000","reminderDays":[7],"note":"","priority":"กลาง"}
]
''',
    });

    final result = await storage.loadReminders();

    expect(result.items.length, 2);
    expect(result.skippedCount, 1);
    expect(result.items[0].id, 'good-001');
    expect(result.items[1].title, 'ใบขับขี่');
  });

  test('clearReminders ล้างข้อมูลแล้ว load ได้ []', () async {
    await storage.saveReminders([
      _sampleItem(id: 'clear-001', title: 'ทดสอบลบ'),
    ]);

    await storage.clearReminders();
    final result = await storage.loadReminders();

    expect(result.items, isEmpty);
  });
}
