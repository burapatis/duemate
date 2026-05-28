import 'package:flutter/material.dart';

import '../home/reminder_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จะพัฒนาในเวอร์ชันถัดไป')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ ตั้งค่าและความเป็นส่วนตัว'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ReminderUi.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔒 ความเป็นส่วนตัว',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('• ข้อมูลหลักเก็บอยู่ในเครื่องนี้'),
                  const SizedBox(height: 4),
                  const Text('• DueMate v0.1.0 ยังไม่ส่งข้อมูลเอกสารขึ้น cloud'),
                  const SizedBox(height: 4),
                  const Text('• ไม่บังคับสมัครสมาชิก'),
                  const SizedBox(height: 4),
                  const Text(
                    '• ไม่เก็บเลขบัตรประชาชน เลขพาสปอร์ต หรือภาพเอกสารสำคัญใน MVP',
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
                    '⚠️ ข้อจำกัดของ v0.1.0',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('• ข้อมูลที่เพิ่มเองยังเป็นข้อมูลชั่วคราว'),
                  const SizedBox(height: 4),
                  const Text('• ปิดแอปแล้วข้อมูลที่เพิ่มเองอาจหายได้'),
                  const SizedBox(height: 4),
                  const Text('• ยังไม่ใช่ระบบแจ้งเตือนจริง'),
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
                    '📋 ข้อจำกัดความรับผิด',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  Text(
                    'DueMate เป็นเครื่องมือช่วยบันทึกและเตือนตามข้อมูลที่ผู้ใช้กรอกเอง ไม่ใช่บริการทางกฎหมาย การเงิน ราชการ หรือประกันภัย',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    'ℹ️ เกี่ยวกับ DueMate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เวอร์ชัน 0.1.0 (MVP)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  // ปุ่มเหล่านี้เป็น placeholder เพื่อให้ flow ใช้งานได้ก่อนใน v0.1.0
                  OutlinedButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text('ทดสอบแจ้งเตือน'),
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  OutlinedButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text('ดูข้อมูลแอปเพิ่มเติม'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
