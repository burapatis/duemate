# DueMate v0.7.1 — Code Quality & Standards Audit

**วันที่ตรวจ:** 2026-05-30  
**ขอบเขต:** อ่านโครงสร้าง `lib/` (16 ไฟล์), `test/` (5 ไฟล์), `docs/`, `pubspec.yaml` และรัน `flutter analyze`  
**ข้อจำกัดรอบนี้:** รายงานเท่านั้น — ยังไม่แก้โค้ด

**ผล `flutter analyze`:** ผ่าน — No issues found

---

## ภาพรวมโครงสร้างโปรเจกต์

```
lib/
├── app.dart, main.dart
├── theme/app_theme.dart
├── features/
│   ├── home/      (dashboard, detail, model, mock, ui)
│   ├── add/       (Add + Edit form)
│   ├── search/
│   ├── export/
│   └── settings/
└── services/
    ├── local_reminder_storage.dart
    ├── notification_service.dart
    ├── export_service.dart
    └── reminder_notification_id.dart
docs/               (beta test pack 3 ไฟล์)
test/               (storage, model, notification id, pdf, widget smoke)
```

- **State management:** StatefulWidget + local state ที่ `HomeDashboardPage` เป็นศูนย์กลาง
- **Routing:** MaterialApp + Navigator.push แบบ imperative
- **ไม่มี:** routing package, DI, repository layer

---

## 1. Flutter/Dart Code Quality

### [Important] ชื่อ method `_saveSample()` และคอมเมนต์ dev-era

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ฟังก์ชันบันทึกจริงยังชื่อ `_saveSample()` พร้อมคอมเมนต์ "ก่อนจะไปเชื่อมฐานข้อมูลจริงในอนาคต" |
| **ไฟล์** | `lib/features/add/add_reminder_page.dart` |
| **เหตุผล** | สื่อว่ายังเป็น prototype ทั้งที่ flow save/persist ทำงานจริงแล้ว — สับสนตอน maintain |
| **วิธีแก้** | Rename เป็น `_saveReminder()` และปรับคอมเมนต์ให้สะท้อน behavior ปัจจุบัน |
| **ถ้าไม่แก้** | ไม่กระทบผู้ใช้ แต่เสี่ยง developer เข้าใจผิดในรอบถัดไป |

### [Important] Duplication: รายการหมวด + format วันที่

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `_categories` ซ้ำใน `add_reminder_page.dart` และ `search_page.dart`; `_formatDate` / `_formatDueLabel` ซ้ำ 4–5 ไฟล์ |
| **ไฟล์** | `add_reminder_page.dart`, `search_page.dart`, `home_dashboard_page.dart`, `reminder_detail_page.dart`, `export_service.dart` |
| **เหตุผล** | แก้หมวดหรือรูปแบบวันที่ต้องแก้หลายที่ — เสี่ยง inconsistent |
| **วิธีแก้** | ย้าย categories + date formatter ไป `reminder_ui.dart` หรือ helper แยก |
| **ถ้าไม่แก้** | Beta ใช้ได้ แต่ refactor ยากขึ้น |

### [Nice to have] Dependency `printing` ไม่ได้ใช้

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `printing` อยู่ใน `pubspec.yaml` แต่ไม่มี import ใน `lib/` |
| **ไฟล์** | `pubspec.yaml` |
| **เหตุผล** | เพิ่มขนาด build, warning Swift Package Manager บน iOS/macOS |
| **วิธีแก้** | ลบถ้าไม่ใช้ หรือใช้จริงใน export |
| **ถ้าไม่แก้** | Warning จาก Flutter ต่อเนื่อง ไม่ block beta |

### [Nice to have] `debugPrint` ใน export PDF

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `export_service.dart` มี `debugPrint` path/size และ stack trace |
| **ไฟล์** | `lib/services/export_service.dart` (บรรทัด ~214–218) |
| **เหตุผล** | Debug-only แต่ทำให้ดูไม่ production-ready |
| **วิธีแก้** | ใช้ `kDebugMode` guard หรือ logging ที่ปิดใน release |
| **ถ้าไม่แก้** | Release build ไม่แสดงให้ผู้ใช้ — ผลกระทบต่ำ |

### [Nice to have] คอมเมนต์ "v0.1.0 / ในขั้นถัดไป"

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | คอมเมนต์เก่าใน `reminder_item.dart`, `reminder_ui.dart`, `reminder_detail_page.dart` |
| **เหตุผล** | ไม่สะท้อน v0.7.0 |
| **วิธีแก้** | อัปเดตคอมเมนต์ให้ตรงปัจจุบัน |
| **ถ้าไม่แก้** | ไม่กระทบ runtime |

**สรุป:** ไม่พบ unused import จาก analyzer, ไม่พบ TODO/FIXME ใน `lib/`

---

## 2. Architecture & Maintainability

### [Important] Services ถูก instantiate ซ้ำในหลายหน้า

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `LocalReminderStorage`, `NotificationService` สร้างใหม่ใน Home, Settings; `NotificationService()` ใหม่ใน Detail ตอนลบ |
| **ไฟล์** | `home_dashboard_page.dart`, `settings_page.dart`, `reminder_detail_page.dart` |
| **เหตุผล** | ยังใช้ได้ (stateless wrapper) แต่ยากต่อการ mock/test แบบ integration และ config ร่วม |
| **วิธีแก้** | v0.8.0: inject ผ่าน constructor หรือ provider เบา ๆ |
| **ถ้าไม่แก้** | Beta ไม่ crash — maintainability ลดลง |

### [Nice to have] ไม่มี repository / domain layer

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | UI เรียก storage + notification โดยตรง |
| **เหตุผล** | โครงสร้าง `features/` + `services/` เหมาะกับขนาดปัจจุบัน |
| **วิธีแก้** | แยก `ReminderRepository` เมื่อ logic ซับซ้อนขึ้น |
| **ถ้าไม่แก้** | ยอมรับได้สำหรับ beta 5–10 คน |

### [Nice to have] `HomeDashboardPage` ใหญ่ (~470 บรรทัด)

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | รวม load/save/navigate/notification/summary/UI |
| **วิธีแก้** | แยก widget ย่อย (ทำบางส่วนแล้ว) หรือ controller class |
| **ถ้าไม่แก้** | อ่านได้อยู่ — ไม่ block beta |

**โดยรวม:** โครงสร้างเหมาะกับ beta — แยก service ชัด ไม่ over-engineered

---

## 3. Reliability / Bug Risk

### [Critical] เวอร์ชันไม่สอดคล้อง (สับสนผู้ทดสอบ)

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | Settings แสดง `0.6.0`, `pubspec.yaml` เป็น `0.1.0+1`, git tag `v0.7.0`, docs อ้าง v0.7.0 |
| **ไฟล์** | `settings_page.dart`, `pubspec.yaml`, `docs/*` |
| **เหตุผล** | ผู้ทดสอบ/ผู้พัฒนาไม่รู้ว่ากำลังทดสอบเวอร์ชันใด — feedback ผิดเวอร์ชัน |
| **วิธีแก้** | Sync เป็น `0.7.1` ทั้ง pubspec, Settings, docs |
| **สถานะ** | ✅ แก้แล้วใน v0.7.1 Step 1 (Sync App Version) |
| **ถ้าไม่แก้** | รายงาน bug ไม่ match codebase |

### [Important] หลัง「ล้างข้อมูล」mock กลับมาใน UI แต่ไม่ persist — จนกว่าจะมี action บันทึก

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `clearReminders()` ล้าง storage แล้ว `_resetToMockData()` แสดง mock ใน memory เท่านั้น; ถ้าผู้ใช้เพิ่มรายการหลังล้าง → `_persistReminders()` จะ **บันทึก mock + รายการใหม่** ลงเครื่อง |
| **ไฟล์** | `home_dashboard_page.dart` (`_resetToMockData`, `_openSettings`), `settings_page.dart` |
| **เหตุผล** | ผู้ใช้คิดว่า「ล้างแล้วเริ่มใหม่」แต่ mock กลับมาถาวรหลัง save |
| **วิธีแก้** | หลัง clear ให้ `_upcomingDocuments = []` หรือ persist `[]` ทันที; แสดง empty state แทน mock |
| **ถ้าไม่แก้** | Beta tester ที่ล้างแล้วเพิ่มรายการจะเห็น mock กลับมา — สับสน |

### [Important] macOS back navigation ยังไม่ครบทุกหน้า

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | มี explicit `leading` + `maybePop` แค่ Add/Settings; **Detail, Search, Export** ใช้ AppBar default |
| **ไฟล์** | `reminder_detail_page.dart`, `search_page.dart`, `export_page.dart` |
| **เหตุผล** | v0.7.0 แก้ Add/Settings แล้ว — หน้าอื่นบน macOS อาจกด `<` ไม่ได้เหมือนเดิม |
| **วิธีแก้** | ใช้ pattern เดียวกับ Add/Settings หรือ shared helper |
| **ถ้าไม่แก้** | macOS tester ติดบางหน้า; Android ไม่กระทบ |

### [Important] บันทึกได้โดยไม่เลือก「เตือนล่วงหน้า」เลย

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | UI บอก「เลือกอย่างน้อย 1 รายการ」แต่ไม่มี validator — uncheck ทั้งหมดแล้ว save ได้ |
| **ไฟล์** | `add_reminder_page.dart` |
| **เหตุผล** | ผู้ใช้คิดว่ามีเตือน แต่ได้ `noSchedulableDates` / ไม่มี notification |
| **วิธีแก้** | validate อย่างน้อย 1 วัน หรือข้อความยืนยันเมื่อไม่เลือก |
| **ถ้าไม่แก้** | feedback「ตั้งเตือนแล้วแต่ไม่เตือน」 |

### [Important] `_updateReminder` ใช้ `firstWhere` ไม่มี orElse

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ถ้า id ไม่พบใน list จะ throw |
| **ไฟล์** | `home_dashboard_page.dart` (บรรทัด ~114–116) |
| **เหตุผล** | edge case จาก state ไม่ sync — crash ได้ |
| **วิธีแก้** | guard `indexWhere` / orElse + early return |
| **ถ้าไม่แก้** | หายากใน beta ปกติ แต่เสี่ยง crash |

### [Nice to have] Add mode ไม่มี unsaved warning

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | Edit มี PopScope + dialog; Add กดกลับแล้วหายโดยไม่เตือน |
| **ไฟล์** | `add_reminder_page.dart` |
| **เหตุผล** | ตั้งใจใน v0.7.0 Step 1.3 — ยัง OK |
| **วิธีแก้** | เพิ่ม dirty check โหมด Add ใน v0.8.0 |
| **ถ้าไม่แก้** | ผู้ใช้ Add แล้วกดกลับอาจเสียข้อมูลโดยไม่รู้ |

### [Nice to have] Search/Export ได้ snapshot ตอน push

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `SearchPage(items: _upcomingDocuments)` — ไม่อัปเดตถ้า Home เปลี่ยนระหว่างเปิด Search |
| **ถ้าไม่แก้** | edge case ไม่ common ใน beta |

**จุดที่ทำงานดี:**

- async/mounted checks ส่วนใหญ่ครบ
- Delete ผ่าน Detail → cancel notification ก่อน pop — ถูกต้อง
- Unsaved Edit: PopScope + `_handleBack` — ครอบคลุม Edit ดี

---

## 4. Data & Persistence

### [Important] `fromJson` throw รายการเดียว → ทั้ง list หาย

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `loadReminders()` catch ทั้งก้อน — ถ้า JSON มี 1 record เสีย → คืน `[]` ทั้งหมด |
| **ไฟล์** | `local_reminder_storage.dart`, `reminder_item.dart` |
| **เหตุผล** | ข้อมูลผู้ใช้หายเงียบ ๆ fallback เป็น mock |
| **วิธีแก้** | parse ทีละรายการ skip ที่เสีย + log; แจ้งผู้ใช้ถ้าเสียบางส่วน |
| **ถ้าไม่แก้** | corrupt 1 field = สูญทั้งหมด |

### [Important] Mock แสดงเมื่อ storage ว่าง — อาจสับสนกับข้อมูลจริง

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ครั้งแรกเปิดแอป / หลัง load fail → แสดง mock 4 รายการเหมือนข้อมูลจริง |
| **ไฟล์** | `home_dashboard_page.dart`, `mock_dashboard_data.dart` |
| **เหตุผล** | Beta tester อาจคิดว่าเป็นเอกสารตัวเอง |
| **วิธีแก้** | แยก「ตัวอย่าง」ชัด ๆ หรือ empty state + CTA เพิ่มรายการ |
| **ถ้าไม่แก้** | สับสนครั้งแรก — test script แนะนำล้างก่อนช่วยได้ |

### [Nice to have] shared_preferences เหมาะ beta แต่มีขีดจำกัด

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ไม่มี migration version, ไม่มี schema validation, ขนาดใหญ่ช้า |
| **ไฟล์** | `local_reminder_storage.dart` (`duemate_reminders_v1`) |
| **วิธีแก้** | v0.8.0+ พิจารณา SQLite/Hive + migration |
| **ถ้าไม่แก้** | beta 5–10 คn / รายการไม่มาก — OK |

### [Nice to have] Migration risk

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | key `_v1` มีแล้ว แต่ยังไม่มี migration path |
| **วิธีแก้** | วางแผน `_v2` + อ่าน v1 fallback |
| **ถ้าไม่แก้** | ยังไม่เร่งก่อน beta |

---

## 5. Notification

### [Important] Android `inexactAllowWhileIdle` — เวลาเตือนไม่แม่นยำ

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ใช้ `AndroidScheduleMode.inexactAllowWhileIdle` — อาจไม่ตรง 09:00 |
| **ไฟล์** | `notification_service.dart` (บรรทัด ~241) |
| **เหตุผล** | Beta tester อาจบอก「เตือนไม่ตรงเวลา」 |
| **วิธีแก้** | แจ้งใน Settings/test script; พิจารณา exact alarm ใน v0.8.0 |
| **ถ้าไม่แก้** | ความคาดหวังผิด — ไม่ใช่ bug logic |

### [Important] Timezone ล็อก `Asia/Bangkok`

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ผู้ใช้นอกไทย / เปลี่ยน timezone อาจได้เวลาเตือนผิด |
| **ไฟล์** | `notification_service.dart` |
| **วิธีแก้** | ใช้ local timezone ของเครื่องใน v0.8.0 |
| **ถ้าไม่แก้** | beta กลุ่มไทย — ยอมรับได้ |

### [Nice to have] Notification ID จาก `Object.hash`

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | theoretically collision; test notification id = 1 อาจชน |
| **ไฟล์** | `reminder_notification_id.dart`, `notification_service.dart` |
| **วิธีแก้** | deterministic range เช่น hash % 100000 + offset |
| **ถ้าไม่แก้** | โอกาสต่ำมากใน beta |

**จุดที่ทำงานดี:**

- reschedule ใช้ `previous` ก่อนแก้ — ดี
- ลบ cancel ใน Detail — ดี
- clear เรียก `cancelAllNotifications()` — ดี

---

## 6. Export CSV/PDF

### [Important] PDF ภาษาไทยอาจแสดงผิด

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | PDF ใช้ default font ของ `pdf` package — คอมเมนต์ระบุ「ภาษาไทยจะปรับใน step ถัดไป」 |
| **ไฟล์** | `export_service.dart` (บรรทัด ~167) |
| **เหตุผล** | ชื่อรายการ/หมวดไทยอาจเป็น □□□ ใน PDF |
| **วิธีแก้** | embed Sarabun/Noto Sans Thai; ทดสอบ export จริง |
| **ถ้าไม่แก้** | ฟีเจอร์「ส่งออก PDF」ล้มใน beta ถ้าทดสอบด้วยข้อความไทย — แจ้งใน test script ว่า CSV น่าเชื่อถือกว่า PDF ชั่วคราว |

### [Important] CSV ไม่มี UTF-8 BOM

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | Excel บางเครื่องเปิด CSV ไทยเพี้ยน |
| **ไฟล์** | `export_service.dart` |
| **วิธีแก้** | เพิ่ม `\uFEFF` BOM หรือแนะนำเปิดด้วย Google Sheets |
| **ถ้าไม่แก้** | feedback「Excel อ่านไม่ได้」 |

### [Nice to have] ไฟล์ export ทับชื่อเดิมเสมอ

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | `duemate_reminders.csv/pdf` fixed name |
| **วิธีแก้** | timestamp ในชื่อไฟล์ |
| **ถ้าไม่แก้** | share ซ้ำทับได้ — ไม่ critical |

**จุดที่ทำงานดี:**

- `share_plus` ใช้ถูกต้อง, มี error handling + SnackBar
- temp/documents path มี fallback — ดี

---

## 7. UI/UX Readiness

### [Important] Settings ยาว — scroll หนัก

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | 5 cards (privacy + beta + guide + clear + about) |
| **ไฟล์** | `settings_page.dart` |
| **เหตุผล** | beta ใช้ได้ แต่ผู้ใช้ทั่วไปอาจ scroll หา「ล้างข้อมูล」 |
| **วิธีแก้** | collapse beta sections หรือ link ไป docs |
| **ถ้าไม่แก้** | ไม่ block — แค่ยาว |

### [Nice to have] Emoji ในหัวข้อทุกหน้า

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | 📋 🔎 ✏️ ➕ — อ่านง่ายบางคน แต่ไม่ formal |
| **วิธีแก้** | เก็บ feedback จาก beta ก่อนตัดสินใจ |
| **ถ้าไม่แก้** | เป็นสไตล์แอป — OK สำหรับ beta |

**จุดที่ทำงานดี:**

- ปุ่มอันตราย (ลบ/ล้าง) ใช้สี error + dialog — ชัดเจน
- Dialog ยืนยัน: ลบ, ล้าง, unsaved edit — ครบ
- ภาษาไทยส่วนใหญ่อ่านง่าย; 「CSV เปิดใน Excel」「ขอบเขต」อาจเทคนิคเล็กน้อย
- Overflow risk ต่ำ — ใช้ Flexible, ListView

---

## 8. Accessibility / WCAG-style

### [Important] ไม่มี Semantics / accessibility label เฉพาะ

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | ไม่มี `Semantics`, `tooltip` บนปุ่ม icon |
| **เหตุผล** | TalkBack/VoiceOver อ่าน generic |
| **วิธีแก้** | เพิ่ม semantic labels ปุ่มกลับ/ลบ/แชร์ |
| **ถ้าไม่แก้** | beta กลุ่มเล็กอาจไม่มีผู้ใช้ screen reader |

### [Nice to have] Priority chip พึ่งสีบางส่วน

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | สูง/กลาง/ต่ำ มีข้อความ + สี — พอใช้ได้ |
| **ถ้าไม่แก้** | ไม่ critical |

### [Nice to have] Touch target

| รายการ | รายละเอียด |
|--------|------------|
| **ปัญหา** | IconButton default ~48dp — โดยทั่วไป OK |
| **CheckboxListTile** | แตะได้ดี |

**font size:** Material 3 default — อ่านได้บนมือถือ ไม่ได้ปรับใหญ่พิเศษ

---

## 9. Privacy / PDPA-style

| หัวข้อ | สถานะ |
|--------|--------|
| ไม่ขอ login/PII | ✅ |
| ข้อมูลเก็บในเครื่อง | ✅ มีข้อความ Home + Settings |
| Settings privacy card | ✅ ชัด |
| docs เตือนไม่ใส่เลขเอกสารจริง | ✅ |
| Export/share | ⚠️ ควรเตือนว่า「ไฟล์ที่แชร์ออกจากเครื่องแล้ว ผู้รับเห็นได้」 — ยังไม่มีใน UI |

**วิธีแก้ export warning:** ข้อความสั้นใน Export page  
**ถ้าไม่แก้:** ความเสี่ยงต่ำสำหรับ beta ที่ทดสอบด้วยข้อมูลตัวอย่าง

---

## 10. Store / Beta Readiness

### Known warnings ที่ควรบันทึก

| Warning | ที่มา |
|---------|--------|
| `printing` ไม่รองรับ Swift Package Manager | `flutter analyze` / build iOS-macOS |
| Kotlin Gradle Plugin จาก plugins | Android build warning |
| PDF ไทย / CSV Excel | ดูหัวข้อ 6 |
| macOS AppBar tap (บางหน้า) | ดูหัวข้อ 3 |
| Notification inexact + timezone Bangkok | ดูหัวข้อ 5 |

---

## Test Coverage สรุป

| มี test | ยังไม่มี test |
|---------|--------------|
| Storage save/load/clear/corrupt JSON | Home navigation flows |
| ReminderItem JSON | Add/Edit form validation |
| Notification ID stability | Delete + notification cancel integration |
| PDF file exists/non-empty | Search filter |
| Widget smoke (Home โหลด) | Settings clear flow |
| | Export share (mock) |

---

## สรุปลำดับความสำคัญ

### Critical (ควรแก้ก่อนให้ผู้ใช้ทดสอบ)

| # | ปัญหา | ไฟล์หลัก |
|---|--------|----------|
| 1 | **เวอร์ชันไม่ตรงกัน** (0.6.0 / 0.1.0 / v0.7.0) | `settings_page.dart`, `pubspec.yaml` |

> **หมายเหตุ:** PDF ไทย **สำคัญมาก** แต่ถ้า test script แจ้งชัดว่า「PDF อาจแสดงไทยไม่ครบ ใช้ CSV แทน」และ beta เน้นทดสอบ flow ไม่ใช่คุณภาพ PDF — จัดเป็น **Important** ได้

### Important (ควรแก้ใน v0.7.1 ถ้าไม่ยาก)

| # | ปัญหา |
|---|--------|
| 1 | หลังล้างข้อมูล mock กลับมาและอาจถูก persist |
| 2 | macOS back ที่ Detail / Search / Export |
| 3 | ไม่ validate reminderDays อย่างน้อย 1 วัน |
| 4 | PDF ไทย + CSV BOM |
| 5 | Duplication categories/date format |
| 6 | `_saveSample` naming |
| 7 | `fromJson` fail ทั้ง list |
| 8 | Mock data สับสนกับข้อมูลจริง |
| 9 | Notification inexact / timezone (แจ้งผู้ทดสอบ) |
| 10 | Test coverage น้อย (ไม่มี widget test flow หลัก) |

### Nice to have (หลังทดสอบจริง / v0.8.0)

| # | ปัญหา |
|---|--------|
| 1 | ลบ dependency `printing` ที่ไม่ใช้ |
| 2 | Repository / DI |
| 3 | Add mode unsaved warning |
| 4 | Migration storage v2 |
| 5 | Accessibility semantics |
| 6 | Export ชื่อไฟล์ unique |
| 7 | Settings collapse / ย่อ beta cards |
| 8 | Notification ID scheme แข็งแรงขึ้น |

---

## สรุปสำหรับผู้พัฒนา

DueMate v0.7.0 **พร้อม beta ในระดับฟังก์ชันหลัก** — analyze ผ่าน, error handling ดี, dialog อันตรายชัด, unsaved edit มีแล้ว, docs ครบ

**ก่อนส่งให้ผู้ใช้ 5–10 คn แนะนำอย่างน้อย:**

1. Sync เวอร์ชันให้ตรงกัน
2. ตัดสินใจ PDF ไทย — แก้ font หรือแจ้งข้อจำกัดใน test script
3. แก้ macOS back หน้าที่เหลือ (ถ้ามี macOS tester)
4. ทบทวน flow「ล้างข้อมูล」ไม่ให้ mock กลับมาเอง

ที่เหลือจัดเป็น v0.7.1 / v0.8.0 ตาม feedback จริงได้

---

## เอกสารที่เกี่ยวข้อง

- [`BETA_TEST_PACK_README.md`](BETA_TEST_PACK_README.md)
- [`REAL_USER_TEST_SCRIPT.md`](REAL_USER_TEST_SCRIPT.md)
- [`FEEDBACK_FORM_TEMPLATE.md`](FEEDBACK_FORM_TEMPLATE.md)

---

*เอกสารนี้เป็นส่วนหนึ่งของ DueMate v0.7.1 — Code Quality Audit (read-only)*
