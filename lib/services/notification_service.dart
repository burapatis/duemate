import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// จัดการ local notifications กลางของแอป DueMate
class NotificationService {
  static const _testNotificationId = 1;
  static const _androidChannelId = 'duemate_general';
  static const _androidChannelName = 'DueMate';
  static const _androidChannelDescription = 'แจ้งเตือนจาก DueMate';

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timezoneReady = false;

  /// โหลด timezone database — ใช้ Asia/Bangkok ชั่วคราวสำหรับผู้ใช้หลักในไทย
  void _initTimeZone() {
    if (_timezoneReady) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    _timezoneReady = true;
  }

  /// มั่นใจว่า plugin พร้อมใช้งานก่อน schedule/cancel
  Future<bool> _ensureReady() async {
    if (_initialized) return true;
    return initialize();
  }

  /// ตั้งค่า plugin เบื้องต้นสำหรับ Android / iOS / macOS — คืน true ถ้าพร้อมใช้งาน
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      _initTimeZone();

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
      final ready = await _ensureReady();
      if (!ready) return false;

      await _plugin.show(
        id: _testNotificationId,
        title: 'DueMate',
        body: 'นี่คือการทดสอบแจ้งเตือน',
        notificationDetails: _notificationDetails,
      );
      return true;
    } catch (_) {
      // แสดงไม่ได้ — ไม่ให้แอป crash
      return false;
    }
  }

  /// ตั้งแจ้งเตือนตามวันเวลา — ยังไม่ผูกกับ dueDate/reminderDays ในรอบนี้
  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final ready = await _ensureReady();
      if (!ready) return;

      // วันเวลาผ่านแล้ว — ไม่ schedule
      if (scheduledDate.isBefore(DateTime.now())) {
        return;
      }

      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: _notificationDetails,
        // inexact ลดความจำเป็นต้องขอ exact alarm permission บน Android
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // schedule ไม่ได้ — ไม่ให้แอป crash
    }
  }

  /// ยกเลิกแจ้งเตือนตาม id
  Future<void> cancelNotification(int id) async {
    try {
      await _ensureReady();
      await _plugin.cancel(id: id);
    } catch (_) {
      // ยกเลิกไม่ได้ — ไม่ throw ต่อ
    }
  }

  /// ยกเลิกแจ้งเตือนที่แสดงอยู่ทั้งหมด
  Future<void> cancelAllNotifications() async {
    try {
      await _ensureReady();
      await _plugin.cancelAll();
    } catch (_) {
      // ยกเลิกไม่ได้ — ไม่ throw ต่อ
    }
  }
}
