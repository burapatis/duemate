import 'package:duemate/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  test('locationNamesForOffset คืน UTC เมื่อ offset เป็นศูนย์', () {
    expect(
      NotificationService.locationNamesForOffset(Duration.zero),
      ['UTC'],
    );
  });

  test('locationNamesForOffset คืน Etc/GMT-7 สำหรับ UTC+7 (ไทย)', () {
    expect(
      NotificationService.locationNamesForOffset(const Duration(hours: 7)),
      ['Etc/GMT-7', 'Asia/Bangkok', 'UTC'],
    );
  });

  test('locationNamesForOffset คืน Asia/Kolkata สำหรับ UTC+5:30', () {
    expect(
      NotificationService.locationNamesForOffset(const Duration(hours: 5, minutes: 30)),
      ['Asia/Kolkata', 'UTC'],
    );
  });

  test('resolveDeviceLocation คืน location ที่โหลดได้', () {
    final location = NotificationService.resolveDeviceLocation();
    expect(location, isA<tz.Location>());
  });
}
