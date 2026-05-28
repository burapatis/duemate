class ReminderUi {
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
}
