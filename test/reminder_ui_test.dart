import 'package:duemate/features/home/reminder_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('categoryEmoji ไม่ซ้ำกันในแต่ละหมวดเอกสาร', () {
    final emojis = ReminderUi.documentCategories
        .map(ReminderUi.categoryEmoji)
        .toList();

    expect(emojis.toSet().length, emojis.length);
  });
}
