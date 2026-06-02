# DueMate v0.8.0 — Pre-Release Quality

**ธีม:** ความน่าเชื่อถือ การแจ้งเตือนที่ชัดเจน และการส่งออกที่ใช้งานได้จริง

**Baseline:** v0.7.1 — Beta Safety Fixes

**Branch:** `release/v0.8.0`

**สถานะ:** ✅ ปิดเวอร์ชันแล้ว — tag `v0.8.0`

---

## Step Checklist

| Step | รายการ | สถานะ |
|------|--------|--------|
| 0.1 | เอกสารแผน v0.8.0 (ไฟล์นี้) | ✅ |
| 1.1 | Parse รายการทีละรายการ | ✅ |
| 1.2 | SnackBar เมื่อโหลดไม่ครบ | ✅ |
| 2.1 | Timezone ตามเครื่อง | ✅ |
| 2.2 | อธิบาย inexact alarm ใน Settings | ✅ |
| 2.4 | Guard `_updateReminder` firstWhere | ✅ |
| 3.1 | PDF ฟอnt ไทย | ✅ |
| 3.2 | ชื่อไฟล์ export มี timestamp | ✅ |
| 3.3 | ข้อความเตือน privacy ใน Export | ✅ |
| 4.1 | แชร์ service instance | ✅ |
| 4.2 | Search ได้ข้อมูลล่าสุด | ✅ |
| 5.1 | Semantics ปุ่มสำคัญ | ✅ |
| 5.2 | Settings ย่อส่วน beta | ✅ |
| 5.3 | ลบ dependency printing | ✅ |
| 6.1 | เพิ่ม unit/widget tests | ✅ |
| 6.2 | อัปเดต docs beta | ✅ |
| 7.1 | Sync เวอร์ชัน 0.8.0 | ✅ |
| 7.2 | Regression + git tag v0.8.0 | ✅ |

---

## Regression Checklist

```bash
flutter analyze
flutter test
flutter run -d macos
```

- [x] Home / Add / Edit / Delete / Search / Detail
- [x] Unsaved warning + reminderDays dialog
- [x] Export CSV/PDF + Share
- [x] Reset → empty state
- [x] Test Notification
- [x] Back ทุกหน้าบน macOS

---

*DueMate v0.8.0 — ปิดเวอร์ชัน Pre-Release Quality*
