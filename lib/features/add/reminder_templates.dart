/// แม่แบบรายการยอดนิยม — ช่วยให้เพิ่มรายการได้เร็วขึ้น
class ReminderTemplate {
  const ReminderTemplate({
    required this.id,
    required this.label,
    required this.emoji,
    required this.titleSuggestion,
    required this.category,
    required this.reminderDays,
  });

  final String id;
  final String label;
  final String emoji;
  final String titleSuggestion;
  final String category;
  final List<int> reminderDays;

  static const custom = ReminderTemplate(
    id: 'custom',
    label: 'กำหนดเอง',
    emoji: '✏️',
    titleSuggestion: '',
    category: 'พ.ร.บ. รถยนต์',
    reminderDays: [7],
  );

  static const List<ReminderTemplate> presets = [
    ReminderTemplate(
      id: 'car_act',
      label: 'พ.ร.บ. รถ',
      emoji: '🚗',
      titleSuggestion: 'พ.ร.บ. รถยนต์',
      category: 'พ.ร.บ. รถยนต์',
      reminderDays: [30, 7],
    ),
    ReminderTemplate(
      id: 'car_insurance',
      label: 'ประกันรถ',
      emoji: '🛡️',
      titleSuggestion: 'ประกันรถยนต์',
      category: 'ประกันรถยนต์',
      reminderDays: [30, 15, 7],
    ),
    ReminderTemplate(
      id: 'driver_license',
      label: 'ใบขับขี่',
      emoji: '🪪',
      titleSuggestion: 'ใบขับขี่',
      category: 'ใบขับขี่',
      reminderDays: [30, 7],
    ),
    ReminderTemplate(
      id: 'vehicle_tax',
      label: 'ภาษีรถ',
      emoji: '🧾',
      titleSuggestion: 'ภาษีรถ / ต่อทะเบียน',
      category: 'ภาษีรถ / ต่อทะเบียน',
      reminderDays: [30, 7],
    ),
    ReminderTemplate(
      id: 'health_insurance',
      label: 'ประกันสุขภาพ',
      emoji: '❤️',
      titleSuggestion: 'ประกันสุขภาพ',
      category: 'ประกันชีวิต / สุขภาพ',
      reminderDays: [30, 15, 7],
    ),
    ReminderTemplate(
      id: 'rental',
      label: 'สัญญาเช่า',
      emoji: '🏠',
      titleSuggestion: 'สัญญาเช่าบ้าน',
      category: 'สัญญาเช่าบ้าน',
      reminderDays: [30, 7],
    ),
    ReminderTemplate(
      id: 'government',
      label: 'นัดราชการ',
      emoji: '🏛️',
      titleSuggestion: 'นัดราชการ',
      category: 'นัดราชการ',
      reminderDays: [7, 1],
    ),
    ReminderTemplate(
      id: 'school',
      label: 'เอกสารลูกเรียน',
      emoji: '🎒',
      titleSuggestion: 'เอกสารลูกเรียน',
      category: 'เอกสารลูกเรียน',
      reminderDays: [15, 7],
    ),
    custom,
  ];
}
