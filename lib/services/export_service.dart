import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../features/home/reminder_item.dart';

/// สร้างไฟล์ export รายการ ReminderItem เป็น CSV/PDF
class ExportService {
  static const _csvFileName = 'duemate_reminders.csv';
  static const _pdfFileName = 'duemate_reminders.pdf';

  /// โฟลเดอร์สำหรับบันทึกไฟล์ export — ใช้ documents ก่อน แล้ว fallback เป็น temp
  Future<Directory> _exportDirectory() async {
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

  /// ส่งออกรายการเป็น PDF พื้นฐาน — คืนไฟล์ที่สร้าง (list ว่างได้)
  Future<File> exportRemindersToPdf(List<ReminderItem> reminders) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DueMate',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'รายงานรายการเอกสาร',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 8),
              pw.Text('จำนวนรายการ: ${reminders.length}'),
              if (reminders.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  'รายการ',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...reminders.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Text(
                      '- ${item.title} (${_formatDate(item.dueDate)})',
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    final bytes = await document.save();
    final directory = await _exportDirectory();
    final file = File('${directory.path}/$_pdfFileName');
    await file.writeAsBytes(bytes);
    return file;
  }
}
