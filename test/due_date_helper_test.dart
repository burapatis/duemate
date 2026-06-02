import 'package:duemate/features/home/due_date_helper.dart';
import 'package:duemate/features/home/reminder_item.dart';
import 'package:flutter_test/flutter_test.dart';

ReminderItem _item(String id, String title, DateTime dueDate) {
  return ReminderItem(
    id: id,
    title: title,
    category: 'อื่น ๆ',
    dueDate: dueDate,
    reminderDays: [7],
    note: '',
    priority: 'กลาง',
  );
}

void main() {
  test('formatDaysRemaining แสดงข้อความเกินกำหนด', () {
    final due = DateTime(2020, 1, 10);
    expect(
      DueDateHelper.formatDaysRemaining(due, isCompleted: false),
      startsWith('เกินกำหนด'),
    );
  });

  test('formatDaysRemaining แสดงเสร็จแล้ว', () {
    expect(
      DueDateHelper.formatDaysRemaining(
        DateTime(2030, 1, 1),
        isCompleted: true,
      ),
      'เสร็จแล้ว',
    );
  });

  test('compareReminders เรียงเกินกำหนดก่อนรายการปกติ', () {
    final overdue = _item('1', 'เกิน', DateTime(2020, 5, 1));
    final normal = _item('2', 'ปกติ', DateTime(2030, 5, 1));
    final sorted = [normal, overdue]..sort(DueDateHelper.compareReminders);

    expect(sorted.first.title, 'เกิน');
  });
}
