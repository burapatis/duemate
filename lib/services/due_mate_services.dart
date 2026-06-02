import 'app_preferences.dart';
import 'export_service.dart';
import 'local_reminder_storage.dart';
import 'notification_service.dart';

/// บริการกลางของแอป — สร้างครั้งเดียวแล้วส่งต่อให้หน้าต่าง ๆ ใช้ร่วมกัน
class DueMateServices {
  DueMateServices({
    LocalReminderStorage? storage,
    NotificationService? notificationService,
    ExportService? exportService,
    AppPreferences? preferences,
  })  : storage = storage ?? LocalReminderStorage(),
        notificationService = notificationService ?? NotificationService(),
        exportService = exportService ?? ExportService(),
        preferences = preferences ?? AppPreferences();

  final LocalReminderStorage storage;
  final NotificationService notificationService;
  final ExportService exportService;
  final AppPreferences preferences;
}
