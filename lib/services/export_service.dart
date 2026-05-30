import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../features/home/reminder_item.dart';

/// สร้างไฟล์ export รายการ ReminderItem เป็น CSV/PDF
class ExportService {
  static const _csvFileName = 'duemate_reminders.csv';
  static const _pdfFileName = 'duemate_reminders.pdf';

  /// ใช้ใน unit test เท่านั้น — กำหนดโฟลเดอร์ export โดยตรง
  @visibleForTesting
  Future<Directory> Function()? exportDirectoryForTesting;

  /// โฟลเดอร์สำหรับบันทึกไฟล์ export — ใช้ documents ก่อน แล้ว fallback เป็น temp
  Future<Directory> _exportDirectory() async {
    if (exportDirectoryForTesting != null) {
      return exportDirectoryForTesting!();
    }

    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }

  /// แปลงวันที่เป็นรูปแบบ dd/MM/yyyy (พ.ศ.) สำหรับ CSV
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year + 543;
    return '$day/$month/$year';
  }

  /// ส่งออกรายการเป็น CSV — คืนไฟล์ที่สร้าง (list ว่างได้ มีแค่ header)
  Future<File> exportRemindersToCsv(List<ReminderItem> reminders) async {
    final rows = <List<String>>[
      const [
        'id',
        'title',
        'category',
        'dueDate',
        'reminderDays',
        'note',
        'priority',
      ],
      ...reminders.map((item) {
        return [
          item.id,
          item.title,
          item.category,
          _formatDate(item.dueDate),
          item.reminderDays.join('|'),
          item.note,
          item.priority,
        ];
      }),
    ];

    final csvContent = csv.encode(rows);
    final directory = await _exportDirectory();
    final file = File('${directory.path}/$_csvFileName');
    await file.writeAsString(csvContent);
    return file;
  }

  /// แปลง reminderDays เป็นข้อความอ่านง่าย — รูปแบบเดียวกับหน้ารายละเอียด
  String _formatReminderDays(List<int> reminderDays) {
    if (reminderDays.isEmpty) return 'ไม่ได้ตั้งค่า';
    final sorted = [...reminderDays]..sort((a, b) => b.compareTo(a));
    return sorted.map((day) => '$day วัน').join(', ');
  }

  /// แถว label + ค่าใน PDF
  pw.Widget _pdfField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  /// กล่องรายการเอกสาร 1 รายการใน PDF
  pw.Widget _buildPdfItem(ReminderItem item) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pdfField('ชื่อรายการ', item.title),
          _pdfField('หมวด', item.category),
          _pdfField('วันครบกำหนด', _formatDate(item.dueDate)),
          _pdfField('เตือนล่วงหน้า', _formatReminderDays(item.reminderDays)),
          if (item.note.isNotEmpty) _pdfField('หมายเหตุ', item.note),
        ],
      ),
    );
  }

  /// ส่วนหัวรายงาน PDF
  pw.Widget _buildPdfHeader(int itemCount, DateTime generatedAt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DueMate',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'รายงานรายการเอกสารและวันครบกำหนด',
          style: const pw.TextStyle(fontSize: 16),
        ),
        pw.SizedBox(height: 12),
        _pdfField('วันที่สร้างรายงาน', _formatDate(generatedAt)),
        _pdfField('จำนวนรายการทั้งหมด', '$itemCount'),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// หมายเหตุท้ายรายงาน PDF
  pw.Widget _buildPdfFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 12),
        pw.Text(
          'รายงานนี้สร้างจากข้อมูลที่ผู้ใช้บันทึกไว้ในเครื่อง',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'DueMate เป็นเครื่องมือช่วยบันทึกและเตือน '
          'ไม่ใช่บริการทางกฎหมาย การเงิน ราชการ หรือประกันภัย',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// ส่งออกรายการเป็น PDF รายงาน — คืนไฟล์ที่สร้าง (list ว่างได้)
  /// ใช้ฟอnt default ของ pdf package (offline ได้) — ภาษาไทยจะปรับใน step ถัดไป
  Future<File> exportRemindersToPdf(List<ReminderItem> reminders) async {
    try {
      final generatedAt = DateTime.now();
      final document = pw.Document();

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return [
              _buildPdfHeader(reminders.length, generatedAt),
              if (reminders.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 24),
                  child: pw.Text(
                    'ยังไม่มีรายการที่บันทึกไว้',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                )
              else
                ...reminders.map(_buildPdfItem),
              _buildPdfFooter(),
            ];
          },
        ),
      );

      final bytes = await document.save();
      if (bytes.isEmpty) {
        throw StateError('PDF bytes ว่าง');
      }

      final directory = await _exportDirectory();
      final file = File('${directory.path}/$_pdfFileName');
      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        throw StateError('ไม่พบไฟล์ PDF หลังเขียน: ${file.path}');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw StateError('ไฟล์ PDF ว่าง: ${file.path}');
      }

      debugPrint('PDF exported: ${file.path} ($fileSize bytes)');
      return file;
    } catch (error, stackTrace) {
      debugPrint('PDF export failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}
