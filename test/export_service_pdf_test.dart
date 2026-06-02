import 'dart:io';

import 'package:duemate/features/home/mock_dashboard_data.dart';
import 'package:duemate/features/home/reminder_item.dart';
import 'package:duemate/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late ExportService exportService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    ExportService.resetPdfThemeCacheForTesting();
    tempDir = await Directory.systemTemp.createTemp('duemate_export_test_');
    exportService = ExportService()
      ..exportDirectoryForTesting = () async => tempDir;
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('buildExportFileName สร้างชื่อไฟล์พร้อม timestamp', () {
    expect(
      ExportService.buildExportFileName(
        extension: 'csv',
        generatedAt: DateTime(2026, 6, 2, 14, 30),
      ),
      'duemate_reminders_20260602_1430.csv',
    );
    expect(
      ExportService.buildExportFileName(
        extension: 'pdf',
        generatedAt: DateTime(2026, 1, 5, 9, 5),
      ),
      'duemate_reminders_20260105_0905.pdf',
    );
  });

  test('exportRemindersToCsv สร้างไฟล์ชื่อไม่ซ้ำตาม timestamp', () async {
    final file = await exportService.exportRemindersToCsv(
      <ReminderItem>[],
      generatedAt: DateTime(2026, 6, 2, 10, 15),
    );

    expect(await file.exists(), isTrue);
    expect(file.uri.pathSegments.last, 'duemate_reminders_20260602_1015.csv');
  });

  test('exportRemindersToPdf สร้างไฟล์ชื่อไม่ซ้ำตาม timestamp', () async {
    final file = await exportService.exportRemindersToPdf(
      MockDashboardData.initialUpcomingDocuments,
      generatedAt: DateTime(2026, 6, 2, 14, 30),
    );

    expect(await file.exists(), isTrue);
    expect(file.uri.pathSegments.last, 'duemate_reminders_20260602_1430.pdf');
    expect(await file.length(), greaterThan(0));
  });

  test('exportRemindersToPdf รองรับรายการว่างโดยไม่ crash', () async {
    final file = await exportService.exportRemindersToPdf(
      <ReminderItem>[],
      generatedAt: DateTime(2026, 6, 2, 8, 0),
    );

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(0));
  });

  test('exportRemindersToPdf รองรับข้อความภาษาไทยและฝังฟอnt', () async {
    final items = [
      ReminderItem(
        id: 'pdf-th-001',
        title: 'พ.ร.บ. รถยนต์',
        category: 'รถ',
        dueDate: DateTime(2026, 12, 15),
        reminderDays: [30, 7],
        note: 'ทดสอบภาษาไทย',
        priority: 'สูง',
      ),
    ];

    final file = await exportService.exportRemindersToPdf(
      items,
      generatedAt: DateTime(2026, 6, 2, 12, 0),
    );

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(5000));
  });
}
