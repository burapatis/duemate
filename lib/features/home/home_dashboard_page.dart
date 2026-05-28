import 'package:flutter/material.dart';

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
  late List<ReminderItem> _upcomingDocuments;

  @override
  void initState() {
    super.initState();
    _upcomingDocuments = List<ReminderItem>.from(
      MockDashboardData.initialUpcomingDocuments,
    );
  }

  Future<void> _openAddReminder() async {
    final newItem = await Navigator.of(context).push<ReminderItem>(
      MaterialPageRoute(
        builder: (_) => const AddReminderPage(),
      ),
    );

    if (newItem == null) return;

    // เพิ่มรายการใหม่เข้า state ทันที (เก็บในหน่วยความจำเท่านั้นสำหรับ v0.1.0)
    setState(() {
      _upcomingDocuments = [newItem, ..._upcomingDocuments];
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกตัวอย่างแล้ว — ขั้นนี้ยังไม่เก็บข้อมูลถาวร'),
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
    final summary = _buildSummary(_upcomingDocuments);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DueMate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ภาพรวมเอกสารสำคัญของคุณ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'เช็กวันครบกำหนดและจัดการรายการได้ในหน้าเดียว',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryCards(summary: summary),
          const SizedBox(height: 24),
          Text(
            'เอกสารใกล้ครบกำหนด',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // แสดงรายการจาก state ปัจจุบัน รวมรายการที่เพิ่งเพิ่มจากหน้า Add
          ..._upcomingDocuments.map(
            (task) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                title: Text(task.title),
                subtitle: Text(
                  '${ReminderUi.categoryEmoji(task.category)} ${task.category} • ${_formatDueLabel(task.dueDate)}',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddReminder,
              icon: const Icon(Icons.add_circle_outline),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('+ เพิ่มรายการใหม่'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchPage(items: _upcomingDocuments),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('ค้นหา'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExportPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.ios_share),
                    label: const Text('ส่งออก'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('ตั้งค่า'),
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
