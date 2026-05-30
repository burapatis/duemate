import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/export_service.dart';
import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.items});

  final List<ReminderItem> items;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static const _csvFormat = 'CSV เปิดใน Excel';
  static const _csvFileName = 'duemate_reminders.csv';

  final _exportService = ExportService();

  String _selectedFileFormat = 'PDF อ่านง่าย';
  String _selectedScope = 'ทั้งหมด';

  /// กรองรายการตามขอบเขตที่ผู้ใช้เลือก
  List<ReminderItem> _filteredItems() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return widget.items.where((item) {
      final due = DateTime(
        item.dueDate.year,
        item.dueDate.month,
        item.dueDate.day,
      );

      return switch (_selectedScope) {
        'เฉพาะรายการใกล้ครบกำหนด' =>
          !due.isBefore(today) && due.difference(today).inDays <= 7,
        'เฉพาะรายการเกินกำหนด' => due.isBefore(today),
        _ => true,
      };
    }).toList();
  }

  /// สร้างไฟล์ CSV แล้วเปิด share sheet ให้ผู้ใช้แชร์หรือบันทึกไฟล์
  Future<void> _createExportFile() async {
    if (_selectedFileFormat != _csvFormat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ฟีเจอร์ส่งออก PDF จะพัฒนาในเวอร์ชันถัดไป'),
        ),
      );
      return;
    }

    try {
      final file = await _exportService.exportRemindersToCsv(_filteredItems());

      // แชร์ไฟล์ CSV — รายการว่างได้ (มีแค่ header)
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          fileNameOverrides: [_csvFileName],
          subject: 'DueMate — รายการเอกสาร',
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปิดหน้าต่างแชร์ไฟล์ CSV แล้ว')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถแชร์ไฟล์ CSV ได้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ส่งออก'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        children: [
          Text(
            '📤 ส่งออกรายการ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'เลือกชนิดไฟล์และขอบเขตข้อมูลก่อนสร้างไฟล์',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: ReminderUi.blockGap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ReminderUi.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รูปแบบไฟล์',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFileFormat,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PDF อ่านง่าย',
                        child: Text('PDF อ่านง่าย'),
                      ),
                      DropdownMenuItem(
                        value: _csvFormat,
                        child: Text('CSV เปิดใน Excel'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedFileFormat = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ReminderUi.sectionGap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ReminderUi.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลที่จะส่งออก',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedScope,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ทั้งหมด',
                        child: Text('ทั้งหมด'),
                      ),
                      DropdownMenuItem(
                        value: 'เฉพาะรายการใกล้ครบกำหนด',
                        child: Text('เฉพาะรายการใกล้ครบกำหนด'),
                      ),
                      DropdownMenuItem(
                        value: 'เฉพาะรายการเกินกำหนด',
                        child: Text('เฉพาะรายการเกินกำหนด'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedScope = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ReminderUi.blockGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _createExportFile,
              icon: const Icon(Icons.file_download_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('สร้างไฟล์ตัวอย่าง'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'CSV ($_csvFileName) จะสร้างแล้วเปิดหน้าต่างแชร์ให้บันทึกหรือส่งต่อ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
