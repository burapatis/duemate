import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// จัดการ local notifications กลางของแอป DueMate
class NotificationService {
  static const _testNotificationId = 1;
  static const _androidChannelId = 'duemate_general';
  static const _androidChannelName = 'DueMate';
  static const _androidChannelDescription = 'แจ้งเตือนจาก DueMate';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// ตั้งค่า plugin เบื้องต้นสำหรับ Android / iOS / macOS — คืน true ถ้าพร้อมใช้งาน
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // ยังไม่ขอ permission ตอน init — เรียก requestPermissions() แยกเมื่อพร้อม
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(settings: initSettings);
      _initialized = true;
      return true;
    } catch (_) {
      // notification ใช้ไม่ได้บน platform นี้ — ไม่ให้แอป crash
      return false;
    }
  }

  /// ขอ permission แจ้งเตือนตาม platform ที่รองรับ
  Future<void> requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (_) {
      // ผู้ใช้ปฏิเสธหรือ platform ไม่รองรับ — ไม่ throw ต่อ
    }
  }

  /// แสดง notification ทดสอบ (ยังไม่เชื่อมกับรายการจริง) — คืน true ถ้าแสดงได้
  Future<bool> showTestNotification() async {
    try {
      if (!_initialized) {
        final ready = await initialize();
        if (!ready) return false;
      }

      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const darwinDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(
        id: _testNotificationId,
        title: 'DueMate',
        body: 'นี่คือการทดสอบแจ้งเตือน',
        notificationDetails: notificationDetails,
      );
      return true;
    } catch (_) {
      // แสดงไม่ได้ — ไม่ให้แอป crash
      return false;
    }
  }
}
