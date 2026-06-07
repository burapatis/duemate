import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/due_mate_services.dart';
import '../../theme/app_brand_colors.dart';
import '../home/reminder_ui.dart';
import '../onboarding/terms_of_use_page.dart';
import '../onboarding/usage_guide_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.services,
    required this.onThemeModeChanged,
    this.embedded = false,
    this.onDataCleared,
  });

  final DueMateServices services;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool embedded;
  final VoidCallback? onDataCleared;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await widget.services.preferences.loadThemeMode();
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await widget.services.preferences.saveThemeMode(mode);
    widget.onThemeModeChanged(mode);
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
    });
  }

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

  DueMateServices get _services => widget.services;

  /// ส่งการแจ้งเตือนตัวอย่างเพื่อตรวจว่าเครื่องอนุญาตให้แจ้งเตือนได้
  Future<void> _testNotification() async {
    try {
      final initialized = await _services.notificationService.initialize();
      if (!initialized) {
        throw StateError('initialize failed');
      }

      await _services.notificationService.requestPermissions();

      final shown = await _services.notificationService.showTestNotification();
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
      await _services.storage.clearReminders();

      // ยกเลิก notification ที่ค้างอยู่ทั้งหมดหลังล้างข้อมูล
      final notificationsCancelled =
          await _services.notificationService.cancelAllNotifications();

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

      // แจ้ง Home ให้เคลิร์ state เป็นรายการว่าง
      if (widget.embedded) {
        widget.onDataCleared?.call();
      } else {
        Navigator.of(context).pop(true);
      }
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

    final body = ListView(
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
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFEEF3FB)
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppBrandColors.primaryBlue.withValues(alpha: 0.14),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.article_outlined,
                    color: AppBrandColors.primaryBlue,
                  ),
                  title: Text(
                    'ข้อตกลงและเงื่อนไขการใช้งาน',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF1B1B2F)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TermsOfUsePage(
                          isOnboarding: false,
                          onAccepted: () async {},
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.menu_book_outlined,
                    color: AppBrandColors.primaryBlue,
                  ),
                  title: Text(
                    'วิธีใช้งานอย่างง่าย',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF1B1B2F)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UsageGuidePage(
                          isOnboarding: false,
                          onCompleted: () async {},
                        ),
                      ),
                    );
                  },
                ),
              ],
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
                    'รูปแบบหน้าจอ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('ตามระบบ'),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('สว่าง'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('มืด'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {_themeMode},
                    onSelectionChanged: (selection) {
                      _setThemeMode(selection.first);
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
                    'การแจ้งเตือน',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• แจ้งเตือนตามวันที่ที่ตั้งไว้ เวลา 09:00 น. ตามเวลาในเครื่องนี้',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• ถ้าเปลี่ยนเขตเวลาในเครื่อง แอปจะใช้เวลาตามเครื่องปัจจุบัน',
                  ),
                  if (defaultTargetPlatform == TargetPlatform.android) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '• บน Android ระบบอาจส่งแจ้งเตือนช้ากว่าเวลาที่ตั้งเล็กน้อย '
                      'เพื่อประหยัดแบตเตอรี่ — ไม่ใช่แอปหยุดทำงาน',
                    ),
                  ],
                  const SizedBox(height: ReminderUi.sectionGap),
                  OutlinedButton(
                    onPressed: _testNotification,
                    child: const Text('ลองส่งการแจ้งเตือน'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ใช้ตรวจว่าเครื่องอนุญาตให้แจ้งเตือนได้',
                    style: mutedStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ReminderUi.sectionGap),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ExpansionTile(
                  title: Text(
                    'ความพร้อมสำหรับทดสอบกลุ่มเล็ก',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'แตะเพื่อดูรายละเอียดสำหรับผู้ทดสอบ',
                    style: mutedStyle,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ReminderUi.cardPadding,
                        0,
                        ReminderUi.cardPadding,
                        ReminderUi.cardPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                  ],
                ),
                const Divider(height: 1),
                ExpansionTile(
                  title: Text(
                    'แนวทางทดสอบกับผู้ใช้จริง',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'แตะเพื่อดูแนวทางจัดการทดสอบ',
                    style: mutedStyle,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ReminderUi.cardPadding,
                        0,
                        ReminderUi.cardPadding,
                        ReminderUi.cardPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _userTestGuideItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $item'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
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
                  ReminderUi.labeledButton(
                    label: 'ล้างข้อมูลทั้งหมดในเครื่อง',
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(color: errorColor),
                      ),
                      onPressed: _confirmClearTestData,
                      child: const Text('ล้างข้อมูลทั้งหมดในเครื่อง'),
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
                    'เกี่ยวกับ DueMate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'แอปช่วยบันทึกและเตือนวันครบกำหนดเอกสารสำคัญ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('DueMate v0.9.0', style: mutedStyle),
                ],
              ),
            ),
          ),
        ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ReminderUi.backButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('ตั้งค่าและความเป็นส่วนตัว'),
      ),
      body: body,
    );
  }
}
