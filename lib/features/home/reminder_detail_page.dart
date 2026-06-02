import 'package:flutter/material.dart';

import '../add/add_reminder_page.dart';
import '../../services/notification_service.dart';
import '../../theme/duemate_widgets.dart';
import 'due_date_helper.dart';
import 'reminder_item.dart';
import 'reminder_ui.dart';

class ReminderDetailPage extends StatelessWidget {
  const ReminderDetailPage({
    super.key,
    required this.item,
    required this.notificationService,
  });

  final ReminderItem item;
  final NotificationService notificationService;

  String _buildReminderLabel(List<int> reminderDays) {
    if (reminderDays.isEmpty) return 'ไม่ได้ตั้งค่า';
    final sorted = [...reminderDays]..sort((a, b) => b.compareTo(a));
    return sorted.map((day) => '$day วัน').join(', ');
  }

  Future<void> _openEdit(BuildContext context) async {
    final updatedItem = await Navigator.of(context).push<ReminderItem>(
      MaterialPageRoute(
        builder: (_) => AddReminderPage(editItem: item),
      ),
    );

    if (updatedItem == null || !context.mounted) return;
    Navigator.of(context).pop(updatedItem);
  }

  Future<void> _openDuplicate(BuildContext context) async {
    final newItem = await Navigator.of(context).push<ReminderItem>(
      MaterialPageRoute(
        builder: (_) => AddReminderPage(copyFrom: item),
      ),
    );

    if (newItem == null || !context.mounted) return;
    Navigator.of(context).pop(newItem);
  }

  Future<void> _toggleCompleted(BuildContext context) async {
    if (!item.isCompleted) {
      final shouldComplete = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('ทำเครื่องหมายเสร็จแล้ว?'),
            content: const Text(
              'รายการนี้จะยังอยู่ในเครื่อง ไม่ถูกลบ '
              'แต่จะไม่แจ้งเตือนอีก และแสดงเป็นรายการที่เสร็จแล้ว',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('เสร็จแล้ว'),
              ),
            ],
          );
        },
      );

      if (shouldComplete != true || !context.mounted) return;
    }

    final updated = item.copyWith(isCompleted: !item.isCompleted);
    if (!context.mounted) return;
    Navigator.of(context).pop(updated);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ลบรายการนี้?'),
          content: Text(
            'คุณต้องการลบ "${item.title}" ออกจากเครื่องนี้หรือไม่',
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
              child: const Text('ลบรายการ'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    await notificationService.cancelRemindersForItem(item);

    if (!context.mounted) return;
    Navigator.of(context).pop(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final urgency = DueDateHelper.urgencyLevel(
      dueDate: item.dueDate,
      isCompleted: item.isCompleted,
    );
    final headerColor = DueDateHelper.urgencyContainerColor(urgency, scheme);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ReminderUi.backButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('รายละเอียด'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        children: [
          Card(
            color: headerColor,
            child: Padding(
              padding: const EdgeInsets.all(ReminderUi.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(ReminderUi.categoryLabel(item.category)),
                  const SizedBox(height: 12),
                  Text(
                    DueDateHelper.formatDaysRemaining(
                      item.dueDate,
                      isCompleted: item.isCompleted,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DueMateWidgets.statusPill(
                    context: context,
                    dueDate: item.dueDate,
                    isCompleted: item.isCompleted,
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
                    'ข้อมูลกำหนดเวลา',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'วันครบกำหนด',
                    value: DueDateHelper.formatThaiDate(item.dueDate),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'เตือนล่วงหน้า',
                    value: _buildReminderLabel(item.reminderDays),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'ความสำคัญ', value: item.priority),
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
                    'หมายเหตุ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(item.note.isEmpty ? '-' : item.note),
                ],
              ),
            ),
          ),
          const SizedBox(height: ReminderUi.blockGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openEdit(context),
              icon: const Icon(Icons.edit),
              label: const Text('แก้ไข'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDuplicate(context),
              icon: const Icon(Icons.copy),
              label: const Text('คัดลอกเป็นรายการใหม่'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _toggleCompleted(context),
              icon: Icon(
                item.isCompleted ? Icons.undo : Icons.check_circle_outline,
              ),
              label: Text(
                item.isCompleted
                    ? 'ทำเครื่องหมายว่ายังไม่เสร็จ'
                    : 'ทำเครื่องหมายเสร็จแล้ว',
              ),
            ),
          ),
          const SizedBox(height: 10),
          ReminderUi.labeledButton(
            label: 'ลบรายการ',
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error),
              ),
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline, color: scheme.error),
              label: const Text('ลบรายการ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Text(': '),
          Flexible(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
