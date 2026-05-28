import 'package:flutter/material.dart';

import 'reminder_item.dart';

class ReminderDetailPage extends StatelessWidget {
  const ReminderDetailPage({super.key, required this.item});

  final ReminderItem item;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year + 543;
    return '$day/$month/$year';
  }

  String _buildStatus(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    // สถานะนี้เป็นกติกาแบบง่ายสำหรับ v0.1.0 เพื่อให้ผู้ใช้เห็นความเร่งด่วน
    if (due.isBefore(today)) return 'เกินกำหนด';
    if (due.difference(today).inDays <= 7) return 'ใกล้ครบกำหนด';
    return 'ปกติ';
  }

  String _buildReminderLabel(List<int> reminderDays) {
    if (reminderDays.isEmpty) return 'ไม่ได้ตั้งค่า';
    final sorted = [...reminderDays]..sort((a, b) => b.compareTo(a));
    return sorted.map((day) => '$day วัน').join(', ');
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จะพัฒนาในขั้นถัดไป')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _buildStatus(item.dueDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดรายการ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailCard(
            label: 'ชื่อรายการ',
            value: item.title,
          ),
          _DetailCard(
            label: 'หมวด',
            value: item.category,
          ),
          _DetailCard(
            label: 'วันครบกำหนด',
            value: _formatDate(item.dueDate),
          ),
          _DetailCard(
            label: 'เตือนล่วงหน้า',
            value: _buildReminderLabel(item.reminderDays),
          ),
          _DetailCard(
            label: 'หมายเหตุ',
            value: item.note.isEmpty ? '-' : item.note,
          ),
          _DetailCard(
            label: 'สถานะ',
            value: status,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showComingSoon(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('แก้ไข'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showComingSoon(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('ลบ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}
