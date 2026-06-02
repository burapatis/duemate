import 'package:flutter/material.dart';

import 'reminder_item.dart';

/// ระดับความเร่งด่วนของวันครบกำหนด — ใช้เรียงรายการและสี UI
enum DueUrgency {
  completed,
  overdue,
  dueToday,
  dueSoon,
  normal,
}

/// คำนวณวันคงเหลือและข้อความแสดงผล — ใช้ร่วมกันทุกหน้า
class DueDateHelper {
  static DateTime calendarDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int daysUntilDue(DateTime dueDate) {
    return calendarDay(dueDate).difference(today()).inDays;
  }

  static DueUrgency urgencyLevel({
    required DateTime dueDate,
    bool isCompleted = false,
  }) {
    if (isCompleted) return DueUrgency.completed;

    final days = daysUntilDue(dueDate);
    if (days < 0) return DueUrgency.overdue;
    if (days == 0) return DueUrgency.dueToday;
    if (days <= 7) return DueUrgency.dueSoon;
    return DueUrgency.normal;
  }

  static int sortOrder(DueUrgency urgency) {
    return switch (urgency) {
      DueUrgency.overdue => 0,
      DueUrgency.dueToday => 1,
      DueUrgency.dueSoon => 2,
      DueUrgency.normal => 3,
      DueUrgency.completed => 4,
    };
  }

  /// ข้อความสั้นสำหรับ badge เช่น "เหลือ 15 วัน" / "เกินกำหนด 3 วัน"
  static String formatDaysRemaining(DateTime dueDate, {bool isCompleted = false}) {
    if (isCompleted) return 'เสร็จแล้ว';

    final days = daysUntilDue(dueDate);
    if (days < 0) return 'เกินกำหนด ${-days} วัน';
    if (days == 0) return 'ครบกำหนดวันนี้';
    if (days == 1) return 'เหลือ 1 วัน';
    return 'เหลือ $days วัน';
  }

  /// สถานะภาษาไทยสำหรับ chip
  static String statusLabel(DateTime dueDate, {bool isCompleted = false}) {
    if (isCompleted) return 'เสร็จแล้ว';

    return switch (urgencyLevel(dueDate: dueDate)) {
      DueUrgency.overdue => 'เกินกำหนด',
      DueUrgency.dueToday => 'ครบวันนี้',
      DueUrgency.dueSoon => 'ใกล้ครบกำหนด',
      DueUrgency.normal => 'ปกติ',
      DueUrgency.completed => 'เสร็จแล้ว',
    };
  }

  static String formatThaiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year + 543;
    return '$day/$month/$year';
  }

  static String formatDueLabel(DateTime dueDate) {
    return 'ครบกำหนด ${formatThaiDate(dueDate)}';
  }

  static Color urgencyColor(DueUrgency urgency, ColorScheme scheme) {
    return switch (urgency) {
      DueUrgency.overdue => scheme.error,
      DueUrgency.dueToday => const Color(0xFFE65100),
      DueUrgency.dueSoon => const Color(0xFFF9A825),
      DueUrgency.completed => scheme.outline,
      DueUrgency.normal => scheme.primary,
    };
  }

  static Color urgencyContainerColor(DueUrgency urgency, ColorScheme scheme) {
    return switch (urgency) {
      DueUrgency.overdue => scheme.errorContainer,
      DueUrgency.dueToday => const Color(0xFFFFE0B2),
      DueUrgency.dueSoon => const Color(0xFFFFF9C4),
      DueUrgency.completed => scheme.surfaceContainerHighest,
      DueUrgency.normal => scheme.primaryContainer,
    };
  }

  static Color urgencyOnContainerColor(DueUrgency urgency, ColorScheme scheme) {
    return switch (urgency) {
      DueUrgency.overdue => scheme.onErrorContainer,
      DueUrgency.dueToday => const Color(0xFFBF360C),
      DueUrgency.dueSoon => const Color(0xFF6D4C00),
      DueUrgency.completed => scheme.onSurfaceVariant,
      DueUrgency.normal => scheme.onPrimaryContainer,
    };
  }

  /// เรียง: เกินกำหนด → วันนี้ → ใกล้ครบ → ปกติ → เสร็จแล้ว (ท้ายสุด)
  static int compareReminders(ReminderItem a, ReminderItem b) {
    final urgencyA = urgencyLevel(
      dueDate: a.dueDate,
      isCompleted: a.isCompleted,
    );
    final urgencyB = urgencyLevel(
      dueDate: b.dueDate,
      isCompleted: b.isCompleted,
    );

    final orderCompare =
        sortOrder(urgencyA).compareTo(sortOrder(urgencyB));
    if (orderCompare != 0) return orderCompare;

    return a.dueDate.compareTo(b.dueDate);
  }
}
