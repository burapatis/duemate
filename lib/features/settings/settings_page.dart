import 'package:flutter/material.dart';

import '../../services/local_reminder_storage.dart';
import '../../services/notification_service.dart';
import '../home/reminder_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _betaChecklistItems = <String>[
    'เพิ่มรายการเอกสาร',
    'แก้ไขรายการ',
    'ลบรายการ',
    'ค้นหาและกรองรายการ',
    'ตั้งเตือนล่วงหน้า',
    'ส่งออกเป็น CSV หรือ PDF',
    'ล้างข้อมูลทั้งหมดในเครื่อง',
  ];

  static const _userTestGuideItems = <String>[
    'แนะนำให้ทดสอบกับผู้ใช้ 5–10 คน',
    'ให้ผู้ใช้ลองเพิ่ม แก้ไข ลบ ค้นหา ตั้งเตือน และส่งออกไฟล์',
    'จดปัญหาที่พบ เช่น อ่านยาก กดผิด หรือไม่เข้าใจข้อความ',
  ];

  final _storage = LocalReminderStorage();
  final _notificationService = NotificationService();

  /// ส่งการแจ้งเตือนตัวอย่างเพื่อตรวจว่าเครื่องอนุญาตให้แจ้งเตือนได้
  Future<void> _testNotification() async {
    try {
      final initialized = await _notificationService.initialize();
      if (!initialized) {
        throw StateError('initialize failed');
      }

      await _notificationService.requestPermissions();

      final shown = await _notificationService.showTestNotification();
      if (!shown) {
        throw StateError('show failed');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งการแจ้งเตือนตัวอย่างแล้ว')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถส่งการแจ้งเตือนได้')),
      );
    }
  }

  Future<void> _confirmClearTestData() async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ลบข้อมูลทั้งหมดในเครื่อง?'),
          content: const Text(
            'รายการทั้งหมดและการแจ้งเตือนที่ตั้งไว้จะถูกลบออกจากเครื่องนี้ '
            'และไม่สามารถกู้คืนได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ลบข้อมูลทั้งหมด'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) return;

    try {
      await _storage.clearReminders();

      // ยกเลิก notification ที่ค้างอยู่ทั้งหมดหลังล้างข้อมูล
      final notificationsCancelled =
          await _notificationService.cancelAllNotifications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notificationsCancelled
                ? 'ล้างข้อมูลและการแจ้งเตือนแล้ว'
                : 'ล้างข้อมูลแล้ว แต่ยังยกเลิกการแจ้งเตือนไม่สำเร็จ',
          ),
        ),
      );

      // แจ้ง Home ให้รีเซ็ต state กลับเป็นรายการเริ่มต้น
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
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        // macOS: AppBar back แบบ default อาจไม่รับ tap — ใช้ leading ชัดเจน
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('ตั้งค่าและความเป็นส่วนตัว'),
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
                    'ความเป็นส่วนตัวและข้อควรทราบ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('• ข้อมูลหลักเก็บอยู่ในเครื่องนี้'),
                  const SizedBox(height: 4),
                  const Text('• ข้อมูลไม่อัปโหลดออกจากเครื่อง'),
                  const SizedBox(height: 4),
                  const Text('• ไม่บังคับสมัครสมาชิก'),
                  const SizedBox(height: 4),
                  const Text(
                    '• ไม่เก็บเลขบัตรประชาชน เลขพาสปอร์ต หรือภาพเอกสารสำคัญ',
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  Text(
                    'DueMate เป็นเครื่องมือช่วยบันทึกและเตือน '
                    'ไม่ใช่บริการทางกฎหมาย การเงิน ราชการ หรือประกันภัย',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'บันทึกรายการ · แจ้งเตือนตามวันที่ · ส่งออกเป็นไฟล์ได้',
                    style: mutedStyle,
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
                    'ความพร้อมสำหรับทดสอบกลุ่มเล็ก',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DueMate เวอร์ชันนี้พร้อมสำหรับการทดสอบเบื้องต้นกับผู้ใช้กลุ่มเล็ก '
                    'เช่น 5–10 คน',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ยังเป็นเวอร์ชันทดสอบ ไม่ใช่เวอร์ชันเผยแพร่จริงบน Store',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  Text('สิ่งที่ควรลองทดสอบ:', style: mutedStyle),
                  const SizedBox(height: 8),
                  ..._betaChecklistItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    ),
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
                    'แนวทางทดสอบกับผู้ใช้จริง',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._userTestGuideItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    ),
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
                    'ล้างข้อมูลในเครื่อง',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'คุณสามารถล้างข้อมูลทั้งหมดในเครื่องได้จากหน้านี้',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ใช้เมื่อต้องการเริ่มต้นใหม่ รายการที่ล้างแล้วไม่สามารถกู้คืนได้',
                  ),
                  const SizedBox(height: ReminderUi.sectionGap),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: BorderSide(color: errorColor),
                    ),
                    onPressed: _confirmClearTestData,
                    child: const Text('ล้างข้อมูลทั้งหมดในเครื่อง'),
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
                    'เกี่ยวกับ DueMate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'แอปช่วยบันทึกและเตือนวันครบกำหนดเอกสารสำคัญ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _testNotification,
                    child: const Text('ลองส่งการแจ้งเตือน'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ใช้ตรวจว่าเครื่องอนุญาตให้แจ้งเตือนได้',
                    style: mutedStyle,
                  ),
                  const SizedBox(height: 8),
                  Text('DueMate v0.7.1', style: mutedStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
