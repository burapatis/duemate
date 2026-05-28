import 'reminder_item.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.dueToday,
    required this.overdue,
    required this.total,
  });

  final int dueToday;
  final int overdue;
  final int total;
}

class MockDashboardData {
  static const initialSummary = DashboardSummary(
    dueToday: 1,
    overdue: 1,
    total: 4,
  );

  static final initialUpcomingDocuments = <ReminderItem>[
    ReminderItem(
      title: 'พ.ร.บ. รถยนต์',
      category: 'รถ',
      dueDate: DateTime(2026, 5, 28),
      reminderDays: [30, 7, 1],
      note: 'ต่ออายุผ่านแอปบริษัทประกัน',
      priority: 'สูง',
    ),
    ReminderItem(
      title: 'ใบขับขี่',
      category: 'ส่วนตัว',
      dueDate: DateTime(2026, 6, 15),
      reminderDays: [30, 7],
      note: '',
      priority: 'กลาง',
    ),
    ReminderItem(
      title: 'ประกันเครื่องซักผ้า',
      category: 'สินค้า/รับประกัน',
      dueDate: DateTime(2026, 7, 22),
      reminderDays: [15, 1],
      note: '',
      priority: 'ต่ำ',
    ),
    ReminderItem(
      title: 'สัญญาเช่าบ้าน',
      category: 'บ้าน',
      dueDate: DateTime(2026, 9, 30),
      reminderDays: [30, 15, 7],
      note: 'คุยสัญญาฉบับใหม่ล่วงหน้า',
      priority: 'สูง',
    ),
  ];
}
