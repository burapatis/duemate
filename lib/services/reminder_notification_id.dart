/// สร้าง notification id คงที่จาก reminder id + จำนวนวันเตือนล่วงหน้า
/// ใช้ตอน schedule/cancel/reschedule ให้ id ตรงกันทุกครั้ง
int reminderNotificationId(String reminderId, int reminderDay) {
  // ไม่ใช้ DateTime.now() — id ต้องคงที่เพื่อ cancel ย้อนหลังได้
  return Object.hash(reminderId, reminderDay).abs();
}

/// สร้าง id ชุดเดียวกันสำหรับ reminderDays ทั้งหมดของรายการ
List<int> reminderNotificationIds(
  String reminderId,
  List<int> reminderDays,
) {
  return reminderDays
      .map((day) => reminderNotificationId(reminderId, day))
      .toList();
}
