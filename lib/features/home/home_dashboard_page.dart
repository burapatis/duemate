import 'package:flutter/material.dart';

import 'mock_dashboard_data.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = MockDashboardData.summary;
    final upcomingDocuments = MockDashboardData.upcomingDocuments;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DueMate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'สรุปเอกสารและวันครบกำหนดของคุณ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _SummaryCards(summary: summary),
          const SizedBox(height: 20),
          Text(
            'เอกสารใกล้ครบกำหนด',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...upcomingDocuments.map(
            (task) => Card(
              child: ListTile(
                title: Text(task.title),
                subtitle: Text(task.dueLabel),
                trailing: _PriorityChip(label: task.priority),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
