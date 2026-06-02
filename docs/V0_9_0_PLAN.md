# DueMate v0.9.0 — Modern UI & Useful Features

**ธีม:** แอปที่ดูสวย ใช้ง่าย และช่วยจัดการเอกสารได้จริงในชีวิตประจำวัน

**Baseline:** v0.8.0 + hotfix ปุ่มกลับ

**Branch:** `release/v0.9.0`

**สถานะ:** ✅ พร้อมทดสอบ — รอ regression บนเครื่องจริง

---

## Step Checklist

| Step | รายการ | สถานะ |
|------|--------|--------|
| 0 | branch + back-fix + เอกสารแผน | ✅ |
| 1 | Design System (Sarabun, theme, widgets) | ✅ |
| 2 | Home redesign (hero, cards, filter, FAB, refresh) | ✅ |
| 3A | Quick Templates | ✅ |
| 3B | Mark completed | ✅ |
| 3C | Duplicate item | ✅ |
| 3D | Days remaining helper | ✅ |
| 4 | Polish Detail/Add/Search/Settings + theme mode | ✅ |
| 5 | Tests + docs + version 0.9.0 | ✅ |

---

## Regression Checklist

```bash
flutter analyze
flutter test
flutter run -d macos
```

- [ ] Home / Add / Edit / Delete / Search / Detail
- [ ] Templates / Complete / Duplicate / Filter / Sort
- [ ] Theme mode ใน Settings
- [ ] Export CSV/PDF + Reset + Notification
- [ ] Back ทุกหน้า กดครั้งเดียว

---

*DueMate v0.9.0 — Modern UI & Useful Features*
