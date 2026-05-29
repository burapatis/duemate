import 'package:flutter/material.dart';

import '../../services/local_reminder_storage.dart';
import '../home/reminder_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = LocalReminderStorage();

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จะพัฒนาในเวอร์ชันถัดไป')),
    );
  }

  Future<void> _confirmClearTestData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ล้างข้อมูลทดสอบ?'),
          content: const Text(
            'รายการที่เพิ่มไว้ในเครื่องนี้จะถูกล้าง และแอปจะกลับไปใช้รายการตัวอย่างเริ่มต้น',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ล้างข้อมูล'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) return;

    try {
      await _storage.clearReminders();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ล้างข้อมูลทดสอบแล้ว')),
      );

      // แจ้ง Home ให้รีเซ็ต state กลับเป็น mock เริ่มต้น
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ล้างข้อมูลไม่สำเร็จ กรุณาลองใหม่')),
      );
    }
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
                    '🧪 ข้อมูลทดสอบ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ใช้สำหรับล้างรายการที่บันทึกไว้ในเครื่องระหว่างทดสอบแอป',
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  OutlinedButton(
                    onPressed: _confirmClearTestData,
                    child: const Text('ล้างข้อมูลทดสอบในเครื่อง'),
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
                  OutlinedButton(
                    onPressed: _showComingSoon,
                    child: const Text('ทดสอบแจ้งเตือน'),
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  OutlinedButton(
                    onPressed: _showComingSoon,
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
