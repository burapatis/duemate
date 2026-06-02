class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.reminderDays,
    required this.note,
    required this.priority,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final List<int> reminderDays;
  final String note;
  final String priority;
  final bool isCompleted;

  ReminderItem copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dueDate,
    List<int>? reminderDays,
    String? note,
    String? priority,
    bool? isCompleted,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'note': note,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = (rawId is String && rawId.isNotEmpty)
        ? rawId
        : DateTime.now().microsecondsSinceEpoch.toString();

    return ReminderItem(
      id: id,
      title: json['title'] as String,
      category: json['category'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      reminderDays: (json['reminderDays'] as List<dynamic>)
          .map((day) => day as int)
          .toList(),
      note: json['note'] as String? ?? '',
      priority: json['priority'] as String? ?? 'กลาง',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
