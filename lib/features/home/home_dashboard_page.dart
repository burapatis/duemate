import 'package:flutter/material.dart';

import '../../services/local_reminder_storage.dart';
import '../add/add_reminder_page.dart';
import '../export/export_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import 'mock_dashboard_data.dart';
import 'reminder_detail_page.dart';
import 'reminder_item.dart';
import 'reminder_ui.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final _storage = LocalReminderStorage();
  bool _isLoading = true;
  List<ReminderItem> _upcomingDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  /// โหลดรายการจากเครื่อง — ถ้าว่างให้ใช้ mock เริ่มต้น
  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stored = await _storage.loadReminders();
      final items = stored.isEmpty
          ? List<ReminderItem>.from(MockDashboardData.initialUpcomingDocuments)
          : stored;

      if (!mounted) return;
      setState(() {
        _upcomingDocuments = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _upcomingDocuments = List<ReminderItem>.from(
          MockDashboardData.initialUpcomingDocuments,
        );
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โหลดข้อมูลไม่สำเร็จ ใช้ข้อมูลเริ่มต้นแทน')),
      );
    }
  }

  /// บันทึกรายการลงเครื่อง — ไม่ให้ crash ถ้าบันทึกไม่สำเร็จ
  Future<void> _persistReminders() async {
    try {
      await _storage.saveReminders(_upcomingDocuments);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกลงเครื่องไม่สำเร็จ กรุณาลองใหม่')),
      );
    }
  }

  Future<void> _openAddReminder() async {
    final newItem = await Navigator.of(context).push<ReminderItem>(
      MaterialPageRoute(
        builder: (_) => const AddReminderPage(),
      ),
    );

    if (newItem == null) return;

    final updatedList = [newItem, ..._upcomingDocuments];
    setState(() {
      _upcomingDocuments = updatedList;
    });

    await _persistReminders();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกรายการแล้ว'),
      ),
    );
  }

  String _formatDueLabel(DateTime dueDate) {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final year = dueDate.year + 543;
    return 'ครบกำหนด $day/$month/$year';
  }

  DashboardSummary _buildSummary(List<ReminderItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueToday = items.where((item) {
      final due = DateTime(item.dueDate.year, item.dueDate.month, item.dueDate.day);
      return due == today;
    }).length;

    final overdue = items.where((item) {
      final due = DateTime(item.dueDate.year, item.dueDate.month, item.dueDate.day);
      return due.isBefore(today);
    }).length;

    return DashboardSummary(
      dueToday: dueToday,
      overdue: overdue,
      total: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('DueMate'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังโหลดข้อมูล...'),
            ],
          ),
        ),
      );
    }

    final summary = _buildSummary(_upcomingDocuments);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DueMate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        children: [
          Text(
            '📋 ภาพรวมเอกสารสำคัญของคุณ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'เช็กวันครบกำหนดและจัดการรายการได้ในหน้าเดียว',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: ReminderUi.blockGap),
          _SummaryCards(summary: summary),
          const SizedBox(height: ReminderUi.blockGap),
          Text(
            '🗂️ เอกสารใกล้ครบกำหนด',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // แสดงรายการจาก state ปัจจุบัน รวมรายการที่เพิ่งเพิ่มจากหน้า Add
          ..._upcomingDocuments.map(
            (task) => Card(
              margin: const EdgeInsets.only(bottom: ReminderUi.sectionGap),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                title: Text(task.title),
                subtitle: Text(
                  '${ReminderUi.categoryLabel(task.category)} • ${_formatDueLabel(task.dueDate)}',
                ),
                trailing: _PriorityChip(label: task.priority),
                onTap: () {
                  // ส่งข้อมูลรายการที่เลือกไปหน้า Detail ทั้งจาก mock และที่เพิ่มใหม่
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReminderDetailPage(item: task),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'หมายเหตุ: ข้อมูลในหน้านี้เป็นข้อมูลจำลองสำหรับ v0.1.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: ReminderUi.blockGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddReminder,
              icon: const Icon(Icons.add_circle_outline),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('เพิ่มรายการใหม่'),
              ),
            ),
          ),
          const SizedBox(height: ReminderUi.sectionGap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ReminderUi.cardPadding),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchPage(items: _upcomingDocuments),
                        ),
                      );
                    },
                    child: const Text('🔎 ค้นหา'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExportPage(),
                        ),
                      );
                    },
                    child: const Text('📤 ส่งออก'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    child: const Text('⚙️ ตั้งค่า'),
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

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'วันนี้',
            value: summary.dueToday.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'เกินกำหนด',
            value: summary.overdue.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'ทั้งหมด',
            value: summary.total.toString(),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = switch (label) {
      'สูง' => colorScheme.errorContainer,
      'กลาง' => colorScheme.tertiaryContainer,
      _ => colorScheme.secondaryContainer,
    };

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
    );
  }
}
