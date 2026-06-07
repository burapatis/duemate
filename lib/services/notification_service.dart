import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../features/home/reminder_item.dart';
import 'reminder_notification_id.dart';

/// ผลการตั้งแจ้งเตือนตาม reminderDays ของรายการ
enum ScheduleRemindersResult {
  /// ตั้งได้ครบทุกวันที่ลอง schedule
  success,

  /// ไม่มี reminderDays หรือวันที่คำนวณได้ทั้งหมดอยู่ในอดีต
  noSchedulableDates,

  /// มีวันที่ควรตั้งได้ แต่บางรายการล้มเหลวหรือระบบไม่พร้อม
  partialFailure,
}

/// จัดการ local notifications กลางของแอป DueMate
class NotificationService {
  static const _defaultReminderHour = 9;
  static const _testNotificationId = 1;
  static const _androidChannelId = 'duemate_general';
  static const _androidChannelName = 'DueMate';
  static const _androidChannelDescription = 'แจ้งเตือนจาก DueMate';

  static const _darwinNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    presentBanner: true,
    presentList: true,
  );

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: _darwinNotificationDetails,
    macOS: _darwinNotificationDetails,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timezoneReady = false;

  /// โหลด timezone database — ใช้ timezone ตาม offset ของเครื่อง (ไม่ล็อก Bangkok)
  void _initTimeZone() {
    if (_timezoneReady) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(resolveDeviceLocation());
    _timezoneReady = true;
  }

  /// หา [tz.Location] จาก timezone offset ของเครื่อง — ใช้ตอน schedule แจ้งเตือน
  static tz.Location resolveDeviceLocation() {
    final offset = DateTime.now().timeZoneOffset;
    final candidates = locationNamesForOffset(offset);

    for (final name in candidates) {
      try {
        return tz.getLocation(name);
      } catch (_) {
        continue;
      }
    }

    debugPrint(
      'DueMate: ใช้ UTC เป็น timezone fallback (offset: $offset)',
    );
    return tz.UTC;
  }

  /// รายชื่อ IANA timezone ที่ลองตามลำดับ — offset ชั่วโมงเต็มใช้ Etc/GMT
  @visibleForTesting
  static List<String> locationNamesForOffset(Duration offset) {
    final totalMinutes = offset.inMinutes;

    if (totalMinutes == 0) {
      return const ['UTC'];
    }

    // offset ไม่เต็มชั่วโมง — ใช้ zone ที่รู้จักก่อน (เช่น อินเดีย +5:30)
    final named = _namedLocationForOffsetMinutes(totalMinutes);
    if (named != null) {
      return [named, 'UTC'];
    }

    final hours = totalMinutes ~/ 60;
    if (totalMinutes % 60 != 0) {
      return const ['UTC'];
    }

    // IANA Etc/GMT: GMT-7 = UTC+7 (เครื่องหมายกลับกับ offset)
    final etcGmt = hours > 0 ? 'Etc/GMT-$hours' : 'Etc/GMT+${hours.abs()}';
    return [etcGmt, 'Asia/Bangkok', 'UTC'];
  }

  static String? _namedLocationForOffsetMinutes(int totalMinutes) {
    const known = <int, String>{
      330: 'Asia/Kolkata',
      345: 'Asia/Kathmandu',
      390: 'Asia/Yangon',
      525: 'Australia/Eucla',
      570: 'Australia/Darwin',
      630: 'Australia/Lord_Howe',
    };
    return known[totalMinutes];
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
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
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

  /// ตรวจว่าเครื่องอนุญาตให้แสดงแจ้งเตือนได้หรือไม่
  Future<bool> hasNotificationPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return options?.isAlertEnabled ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return options?.isAlertEnabled ?? false;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final enabled = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return enabled ?? true;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// ขอ permission แจ้งเตือน — คืน true ถ้าเครื่องอนุญาตแล้ว
  Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      if (defaultTargetPlatform == TargetPlatform.macOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      return hasNotificationPermission();
    } catch (_) {
      return false;
    }
  }

  /// แสดง notification ทดสอบ (ยังไม่เชื่อมกับรายการจริง) — คืน true ถ้าแสดงได้
  Future<bool> showTestNotification() async {
    try {
      final ready = await _ensureReady();
      if (!ready) return false;

      final permitted = await requestPermissions();
      if (!permitted) return false;

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

  /// คำนวณวันเวลาแจ้งเตือน: dueDate − reminderDay ที่ 09:00 น.
  DateTime _scheduledAt(DateTime dueDate, int reminderDay) {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final reminderDayDate = dueDay.subtract(Duration(days: reminderDay));
    return DateTime(
      reminderDayDate.year,
      reminderDayDate.month,
      reminderDayDate.day,
      _defaultReminderHour,
    );
  }

  /// ตั้งแจ้งเตือนตาม dueDate และ reminderDays ของรายการ
  Future<ScheduleRemindersResult> scheduleRemindersForItem(
    ReminderItem item,
  ) async {
    if (item.reminderDays.isEmpty) {
      return ScheduleRemindersResult.noSchedulableDates;
    }

    try {
      final initialized = await initialize();
      if (!initialized) {
        return _hasAnyFutureScheduleDate(item)
            ? ScheduleRemindersResult.partialFailure
            : ScheduleRemindersResult.noSchedulableDates;
      }

      await requestPermissions();

      var attempted = 0;
      var succeeded = 0;

      for (final reminderDay in item.reminderDays) {
        final scheduledDate = _scheduledAt(item.dueDate, reminderDay);

        // วันเวลาผ่านแล้ว — ข้าม
        if (scheduledDate.isBefore(DateTime.now())) {
          continue;
        }

        attempted++;
        final ok = await scheduleReminderNotification(
          id: reminderNotificationId(item.id, reminderDay),
          title: 'DueMate',
          body: 'ใกล้ถึงกำหนด: ${item.title}',
          scheduledDate: scheduledDate,
        );
        if (ok) succeeded++;
      }

      if (attempted == 0) {
        return ScheduleRemindersResult.noSchedulableDates;
      }
      if (succeeded == attempted) {
        return ScheduleRemindersResult.success;
      }
      return ScheduleRemindersResult.partialFailure;
    } catch (_) {
      return ScheduleRemindersResult.partialFailure;
    }
  }

  bool _hasAnyFutureScheduleDate(ReminderItem item) {
    final now = DateTime.now();
    for (final reminderDay in item.reminderDays) {
      if (!_scheduledAt(item.dueDate, reminderDay).isBefore(now)) {
        return true;
      }
    }
    return false;
  }

  /// ตั้งแจ้งเตือนตามวันเวลา — คืน true ถ้าสำเร็จ
  Future<bool> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final ready = await _ensureReady();
      if (!ready) return false;

      // วันเวลาผ่านแล้ว — ไม่ schedule
      if (scheduledDate.isBefore(DateTime.now())) {
        return false;
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
      return true;
    } catch (_) {
      // schedule ไม่ได้ — ไม่ให้แอป crash
      return false;
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

  /// ยกเลิกแจ้งเตือนทั้งหมดที่เกี่ยวกับรายการ (ใช้ helper id จาก Step 2)
  Future<void> cancelRemindersForItem(ReminderItem item) async {
    try {
      final notificationIds =
          reminderNotificationIds(item.id, item.reminderDays);

      for (final id in notificationIds) {
        await cancelNotification(id);
      }
    } catch (_) {
      // ยกเลิกไม่ได้ — ไม่ให้แอป crash
    }
  }

  /// ยกเลิกแจ้งเตือนเดิมแล้วตั้งใหม่ตามข้อมูลล่าสุด (ใช้หลังแก้ไขรายการ)
  Future<ScheduleRemindersResult> rescheduleRemindersForItem({
    required ReminderItem previous,
    required ReminderItem updated,
  }) async {
    try {
      // ยกเลิกตาม reminderDays เดิมก่อนแก้ไข
      await cancelRemindersForItem(previous);
      return scheduleRemindersForItem(updated);
    } catch (_) {
      return ScheduleRemindersResult.partialFailure;
    }
  }

  /// ยกเลิกแจ้งเตือนที่แสดงอยู่และที่ schedule ค้างอยู่ทั้งหมด — คืน true ถ้าสำเร็จ
  Future<bool> cancelAllNotifications() async {
    try {
      final ready = await _ensureReady();
      if (!ready) return false;

      await _plugin.cancelAllPendingNotifications();
      await _plugin.cancelAll();
      return true;
    } catch (_) {
      // ยกเลิกไม่ได้ — ไม่ throw ต่อ
      return false;
    }
  }
}
