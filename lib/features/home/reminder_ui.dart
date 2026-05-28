/// ค่ามาตรฐาน UI และข้อความหมวดเอกสาร (v0.1.0)
class ReminderUi {
  static const double pagePadding = 16;
  static const double cardPadding = 14;
  static const double sectionGap = 12;
  static const double blockGap = 16;

  static String categoryEmoji(String category) {
    switch (category) {
      case 'รถ':
        return '🚗';
      case 'บ้าน':
        return '🏠';
      case 'ส่วนตัว':
        return '👤';
      case 'ครอบครัว':
        return '👨‍👩‍👧';
      case 'สินค้า/รับประกัน':
        return '📦';
      case 'งาน/ราชการ':
        return '🏛️';
      default:
        return '📝';
    }
  }

  /// ข้อความหมวดพร้อม emoji ชุดเดียว — ใช้ในรายการ ไม่ใส่ Icon ซ้ำ
  static String categoryLabel(String category) {
    return '${categoryEmoji(category)} $category';
  }

  /// ตัวเลือกกรองหมวด (รวม "ทั้งหมด")
  static String filterCategoryLabel(String category) {
    if (category == 'ทั้งหมด') return category;
    return categoryLabel(category);
  }
}
