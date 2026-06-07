import 'package:flutter/material.dart';

import '../features/home/due_date_helper.dart';
import '../features/home/reminder_item.dart';
import '../features/home/reminder_ui.dart';
import 'app_brand_colors.dart';
import 'app_branding.dart';

/// Widget กลางของ DueMate — สไตล์ DOCSAFE
class DueMateWidgets {
  static Widget sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  /// Header gradient พร้อมโลโก้ ช่องค้นหา และปุ่มกรอง
  static Widget docsafeHeader({
    required BuildContext context,
    required VoidCallback onSearchTap,
    required VoidCallback onFilterTap,
    required VoidCallback onSettingsTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppBrandColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppBranding.displayNameTh,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                      ),
                      Text(
                        AppBranding.displayNameEn,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onSettingsTap,
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    tooltip: 'ตั้งค่า',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: onSearchTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'ค้นหาเอกสาร...',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppBrandColors.gradientEnd,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onFilterTap,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// การ์ดสรุปสีทึบแบบ DOCSAFE
  static Widget coloredSummaryCard({
    required Color background,
    required String label,
    required int count,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$count รายการ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (Color bg, Color fg) badgeColors(
    DueUrgency urgency,
    ColorScheme scheme,
  ) {
    return switch (urgency) {
      DueUrgency.overdue || DueUrgency.dueToday => (
          AppBrandColors.badgeOrange,
          Colors.white,
        ),
      DueUrgency.dueSoon => (AppBrandColors.badgeYellow, Colors.black87),
      DueUrgency.normal => (AppBrandColors.badgeGreen, Colors.white),
      DueUrgency.completed => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
    };
  }

  static String badgeText(DateTime dueDate, {bool isCompleted = false}) {
    if (isCompleted) return 'เสร็จแล้ว';

    final days = DueDateHelper.daysUntilDue(dueDate);
    if (days < 0) return 'หมดอายุแล้ว';
    if (days == 0) return 'ครบวันนี้';
    return '$days วันที่คงเหลือ';
  }

  static Widget statusPill({
    required BuildContext context,
    required DateTime dueDate,
    bool isCompleted = false,
  }) {
    final urgency = DueDateHelper.urgencyLevel(
      dueDate: dueDate,
      isCompleted: isCompleted,
    );
    final (bg, fg) = badgeColors(urgency, Theme.of(context).colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        badgeText(dueDate, isCompleted: isCompleted),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget docsafeDocumentCard({
    required BuildContext context,
    required ReminderItem item,
    required VoidCallback onTap,
  }) {
    final emoji = ReminderUi.categoryEmoji(item.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: item.isCompleted
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppBrandColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exp: ${DueDateHelper.formatThaiDate(item.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              statusPill(
                context: context,
                dueDate: item.dueDate,
                isCompleted: item.isCompleted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget viewAllButton({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppBrandColors.primaryBlue,
          side: const BorderSide(color: AppBrandColors.primaryBlue),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: const Text('ดูเอกสารทั้งหมด'),
      ),
    );
  }

  static Widget emptyStateCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppBrandColors.primaryBlue.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ใช้ใน Search — รักษา layout เดียวกับหน้าหลัก
  static Widget reminderListTile({
    required BuildContext context,
    required ReminderItem item,
    required VoidCallback onTap,
  }) {
    return docsafeDocumentCard(
      context: context,
      item: item,
      onTap: onTap,
    );
  }
}
