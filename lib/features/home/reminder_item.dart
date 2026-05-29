class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.reminderDays,
    required this.note,
    required this.priority,
  });

  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final List<int> reminderDays;
  final String note;
  final String priority;

  /// แปลงเป็น JSON สำหรับบันทึกลง shared_preferences ในขั้นถัดไป
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'note': note,
      'priority': priority,
    };
  }

  /// สร้างจาก JSON ที่อ่านจาก shared_preferences
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
    );
  }
}
