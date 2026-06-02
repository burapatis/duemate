import 'package:duemate/services/app_preferences.dart';
import 'package:duemate/services/due_mate_services.dart';
import 'package:duemate/services/export_service.dart';
import 'package:duemate/services/local_reminder_storage.dart';
import 'package:duemate/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DueMateServices สร้าง service กลางครบชุด', () {
    final services = DueMateServices();

    expect(services.storage, isA<LocalReminderStorage>());
    expect(services.notificationService, isA<NotificationService>());
    expect(services.exportService, isA<ExportService>());
    expect(services.preferences, isA<AppPreferences>());
  });

  test('DueMateServices รับ service ที่ inject ได้', () {
    final storage = LocalReminderStorage();
    final notificationService = NotificationService();
    final exportService = ExportService();

    final services = DueMateServices(
      storage: storage,
      notificationService: notificationService,
      exportService: exportService,
    );

    expect(services.storage, same(storage));
    expect(services.notificationService, same(notificationService));
    expect(services.exportService, same(exportService));
  });
}
