import 'package:duemate/features/home/reminder_item.dart';
import 'package:duemate/features/search/search_page.dart';
import 'package:flutter_test/flutter_test.dart';

ReminderItem _item({
  required String id,
  required String title,
  String category = 'รถ',
}) {
  return ReminderItem(
    id: id,
    title: title,
    category: category,
    dueDate: DateTime(2026, 12, 1),
    reminderDays: const [7],
    note: '',
    priority: 'กลาง',
  );
}

void main() {
  final items = [
    _item(id: '1', title: 'พ.ร.บ. รถยนต์', category: 'รถ'),
    _item(id: '2', title: 'ใบขับขี่', category: 'ส่วนตัว'),
    _item(id: '3', title: 'ประกันบ้าน', category: 'บ้าน'),
  ];

  test('filterReminderItems คืนทั้งหมดเมื่อไม่มีคำค้นหาและหมวดทั้งหมด', () {
    final result = filterReminderItems(
      items: items,
      query: '',
      selectedCategory: 'ทั้งหมด',
    );

    expect(result.length, 3);
  });

  test('filterReminderItems กรองตามชื่อ', () {
    final result = filterReminderItems(
      items: items,
      query: 'ใบขับ',
      selectedCategory: 'ทั้งหมด',
    );

    expect(result.length, 1);
    expect(result.first.title, 'ใบขับขี่');
  });

  test('filterReminderItems กรองตามหมวด', () {
    final result = filterReminderItems(
      items: items,
      query: '',
      selectedCategory: 'บ้าน',
    );

    expect(result.length, 1);
    expect(result.first.title, 'ประกันบ้าน');
  });

  test('filterReminderItems กรองชื่อและหมวดพร้อมกัน', () {
    final result = filterReminderItems(
      items: items,
      query: 'รถ',
      selectedCategory: 'รถ',
    );

    expect(result.length, 1);
    expect(result.first.title, 'พ.ร.บ. รถยนต์');
  });

  test('filterReminderItems รองรับหมวดเก่าเมื่อกรองด้วยหมวดใหม่', () {
    final result = filterReminderItems(
      items: items,
      query: '',
      selectedCategory: 'พ.ร.บ. รถยนต์',
    );

    expect(result.length, 1);
    expect(result.first.title, 'พ.ร.บ. รถยนต์');
  });

  test('filterReminderItems ค้นหาด้วยชื่อหมวดใหม่ของรายการเก่า', () {
    final result = filterReminderItems(
      items: items,
      query: 'ใบขับขี่',
      selectedCategory: 'ทั้งหมด',
    );

    expect(result.length, 1);
    expect(result.first.category, 'ส่วนตัว');
  });

  test('filterReminderItems ซ่อนรายการที่เสร็จแล้ว', () {
    final withCompleted = [
      ...items,
      _item(
        id: '4',
        title: 'เสร็จแล้ว',
        category: 'อื่น ๆ',
      ).copyWith(isCompleted: true),
    ];

    final result = filterReminderItems(
      items: withCompleted,
      query: '',
      selectedCategory: 'ทั้งหมด',
      hideCompleted: true,
    );

    expect(result.length, 3);
    expect(result.any((item) => item.isCompleted), isFalse);
  });

  test('filterReminderItems เรียงตามความเร่งด่วน', () {
    final urgentItems = [
      _item(id: 'a', title: 'ปกติ', category: 'อื่น ๆ'),
      _item(id: 'b', title: 'ใกล้ครบ', category: 'อื่น ๆ'),
      _item(id: 'c', title: 'เกินกำหนด', category: 'อื่น ๆ'),
    ];

    final result = filterReminderItems(
      items: [
        urgentItems[0].copyWith(
          dueDate: DateTime.now().add(const Duration(days: 30)),
        ),
        urgentItems[1].copyWith(
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        urgentItems[2].copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      query: '',
      selectedCategory: 'ทั้งหมด',
    );

    expect(result.first.title, 'เกินกำหนด');
    expect(result.last.title, 'ปกติ');
  });
}
