class ReminderItem {
  const ReminderItem({
    required this.title,
    required this.category,
    required this.dueDate,
    required this.reminderDays,
    required this.note,
    required this.priority,
  });

  final String title;
  final String category;
  final DateTime dueDate;
  final List<int> reminderDays;
  final String note;
  final String priority;
}
