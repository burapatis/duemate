import 'package:duemate/features/home/reminder_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson และ fromJson คืนค่ารายการเดิมได้', () {
    final original = ReminderItem(
      id: 'test-001',
      title: 'ใบขับขี่',
      category: 'ส่วนตัว',
      dueDate: DateTime(2026, 6, 15),
      reminderDays: [30, 7, 1],
      note: 'ทดสอบหมายเหตุ',
      priority: 'กลาง',
    );

    final restored = ReminderItem.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.category, original.category);
    expect(restored.dueDate, original.dueDate);
    expect(restored.reminderDays, original.reminderDays);
    expect(restored.note, original.note);
    expect(restored.priority, original.priority);
    expect(restored.isCompleted, original.isCompleted);
  });

  test('fromJson รองรับข้อมูลเก่าที่ไม่มี isCompleted', () {
    final restored = ReminderItem.fromJson({
      'id': 'legacy',
      'title': 'ทดสอบ',
      'category': 'อื่น ๆ',
      'dueDate': '2026-01-01T00:00:00.000',
      'reminderDays': [7],
      'note': '',
      'priority': 'กลาง',
    });

    expect(restored.isCompleted, false);
  });

  test('dueDate บันทึกเป็น ISO 8601 string', () {
    final item = ReminderItem(
      id: 'test-002',
      title: 'พ.ร.บ. รถยนต์',
      category: 'รถ',
      dueDate: DateTime(2026, 5, 28),
      reminderDays: [7],
      note: '',
      priority: 'สูง',
    );

    final json = item.toJson();

    expect(json['dueDate'], '2026-05-28T00:00:00.000');
    expect(json['reminderDays'], [7]);
  });

  test('fromJson สร้าง id ใหม่เมื่อ id ว่างหรือไม่มี', () {
    final restored = ReminderItem.fromJson({
      'title': 'ทดสอบ',
      'category': 'อื่น ๆ',
      'dueDate': '2026-01-01T00:00:00.000',
      'reminderDays': [7],
      'note': '',
      'priority': 'กลาง',
    });

    expect(restored.id, isNotEmpty);
    expect(restored.title, 'ทดสอบ');
  });
}
