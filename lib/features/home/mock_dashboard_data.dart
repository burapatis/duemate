import 'reminder_item.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.expiringSoon,
    required this.nearing,
    required this.normal,
  });

  /// หมดอายุเร็วๆ นี้ — เกินกำหนด + ครบวันนี้
  final int expiringSoon;

  /// ใกล้หมดอายุ — เหลือ 1–7 วัน
  final int nearing;

  /// ปกติ — เหลือมากกว่า 7 วัน
  final int normal;
}

class MockDashboardData {
  static const initialSummary = DashboardSummary(
    expiringSoon: 2,
    nearing: 0,
    normal: 2,
  );

  static final initialUpcomingDocuments = <ReminderItem>[
    ReminderItem(
      id: 'mock_car_act',
      title: 'พ.ร.บ. รถยนต์',
      category: 'รถ',
      dueDate: DateTime(2026, 5, 28),
      reminderDays: [30, 7, 1],
      note: 'ต่ออายุผ่านแอปบริษัทประกัน',
      priority: 'สูง',
    ),
    ReminderItem(
      id: 'mock_driver_license',
      title: 'ใบขับขี่',
      category: 'ส่วนตัว',
      dueDate: DateTime(2026, 6, 15),
      reminderDays: [30, 7],
      note: '',
      priority: 'กลาง',
    ),
    ReminderItem(
      id: 'mock_warranty_washing_machine',
      title: 'ประกันเครื่องซักผ้า',
      category: 'สินค้า/รับประกัน',
      dueDate: DateTime(2026, 7, 22),
      reminderDays: [15, 1],
      note: '',
      priority: 'ต่ำ',
    ),
    ReminderItem(
      id: 'mock_house_rental_contract',
      title: 'สัญญาเช่าบ้าน',
      category: 'บ้าน',
      dueDate: DateTime(2026, 9, 30),
      reminderDays: [30, 15, 7],
      note: 'คุยสัญญาฉบับใหม่ล่วงหน้า',
      priority: 'สูง',
    ),
  ];
}
