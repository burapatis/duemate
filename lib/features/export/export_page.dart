import 'package:flutter/material.dart';

import '../home/reminder_ui.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedFileFormat = 'PDF อ่านง่าย';
  String _selectedScope = 'ทั้งหมด';

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
            'เลือกชนิดไฟล์และขอบเขตข้อมูลก่อนสร้างไฟล์ตัวอย่าง',
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
                        value: 'CSV เปิดใน Excel',
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
              onPressed: () {
                // v0.1.0 มีไว้ทดสอบ flow หน้าจอ ยังไม่สร้างไฟล์จริง
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ฟีเจอร์ส่งออกไฟล์จะพัฒนาในเวอร์ชันถัดไป'),
                  ),
                );
              },
              icon: const Icon(Icons.file_download_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('สร้างไฟล์ตัวอย่าง'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'v0.1.0 ยังไม่สร้างไฟล์จริง เพื่อทดสอบโครงหน้าจอเท่านั้น',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
