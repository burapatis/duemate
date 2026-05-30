import 'dart:io';

import 'package:duemate/features/home/mock_dashboard_data.dart';
import 'package:duemate/features/home/reminder_item.dart';
import 'package:duemate/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late ExportService exportService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('duemate_pdf_test_');
    exportService = ExportService()
      ..exportDirectoryForTesting = () async => tempDir;
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exportRemindersToPdf สร้างไฟล์ duemate_reminders.pdf ที่มีอยู่จริง', () async {
    final file = await exportService.exportRemindersToPdf(
      MockDashboardData.initialUpcomingDocuments,
    );

    expect(await file.exists(), isTrue);
    expect(file.path.endsWith('duemate_reminders.pdf'), isTrue);
    expect(await file.length(), greaterThan(0));
  });

  test('exportRemindersToPdf รองรับรายการว่างโดยไม่ crash', () async {
    final file = await exportService.exportRemindersToPdf(<ReminderItem>[]);

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(0));
  });
}
