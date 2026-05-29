import 'package:duemate/services/reminder_notification_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminderNotificationId คืนค่าเดิมเมื่อ input เดิม', () {
    final id1 = reminderNotificationId('mock_car_act', 7);
    final id2 = reminderNotificationId('mock_car_act', 7);

    expect(id1, id2);
  });

  test('reminderNotificationId ไม่เป็นค่าลบ', () {
    final id = reminderNotificationId('mock_driver_license', 30);
    expect(id, greaterThanOrEqualTo(0));
  });

  test('reminderId ต่างกันให้ id ต่างกัน', () {
    final carAct = reminderNotificationId('mock_car_act', 7);
    final driverLicense = reminderNotificationId('mock_driver_license', 7);

    expect(carAct, isNot(driverLicense));
  });

  test('reminderDay ต่างกันให้ id ต่างกัน', () {
    final sevenDays = reminderNotificationId('mock_car_act', 7);
    final thirtyDays = reminderNotificationId('mock_car_act', 30);

    expect(sevenDays, isNot(thirtyDays));
  });

  test('reminderNotificationIds คืน id ตามจำนวนวันเตือน', () {
    final ids = reminderNotificationIds('item-001', [30, 7, 1]);

    expect(ids.length, 3);
    expect(ids[0], reminderNotificationId('item-001', 30));
    expect(ids[1], reminderNotificationId('item-001', 7));
    expect(ids[2], reminderNotificationId('item-001', 1));
  });
}
