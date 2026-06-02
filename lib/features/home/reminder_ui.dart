import 'package:flutter/material.dart';

/// ค่ามาตรฐาน UI และหมวดเอกสารสำหรับผู้ใช้ไทย
class ReminderUi {
  static const double pagePadding = 16;
  static const double cardPadding = 14;
  static const double sectionGap = 12;
  static const double blockGap = 16;

  /// หมวดเอกสารที่คนไทยมักต้องจำ — เลือกได้เลย ไม่ต้องพิมพ์เอง
  static const documentCategories = <String>[
    'พ.ร.บ. รถยนต์',
    'ประกันรถยนต์',
    'ใบขับขี่',
    'ภาษีรถ / ต่อทะเบียน',
    'พ.ร.บ. มอเตอร์ไซค์',
    'ประกันชีวิต / สุขภาพ',
    'ประกันบ้าน / คอนโด',
    'สัญญาเช่าบ้าน',
    'สัญญาเช่าซื้อ / ผ่อน',
    'นัดราชการ',
    'เอกสารลูกเรียน',
    'ใบอนุญาตทำงาน / วีซ่า',
    'สมาชิก / บัตรส่วนลด',
    'อื่น ๆ',
  ];

  /// ใช้ใน dropdown กรอง — รวม "ทั้งหมด"
  static List<String> get filterCategories => [
        'ทั้งหมด',
        ...documentCategories,
      ];

  static String categoryEmoji(String category) {
    switch (category) {
      case 'พ.ร.บ. รถยนต์':
      case 'ประกันรถยนต์':
      case 'ภาษีรถ / ต่อทะเบียน':
      case 'รถ':
        return '🚗';
      case 'พ.ร.บ. มอเตอร์ไซค์':
        return '🏍️';
      case 'ใบขับขี่':
      case 'ส่วนตัว':
        return '🪪';
      case 'ประกันชีวิต / สุขภาพ':
        return '❤️';
      case 'ประกันบ้าน / คอนโด':
      case 'สัญญาเช่าบ้าน':
      case 'บ้าน':
        return '🏠';
      case 'สัญญาเช่าซื้อ / ผ่อน':
        return '💳';
      case 'นัดราชการ':
      case 'งาน/ราชการ':
        return '🏛️';
      case 'เอกสารลูกเรียน':
      case 'ครอบครัว':
        return '🎒';
      case 'ใบอนุญาตทำงาน / วีซ่า':
        return '🛂';
      case 'สมาชิก / บัตรส่วนลด':
        return '🎫';
      case 'สินค้า/รับประกัน':
        return '📦';
      default:
        return '📝';
    }
  }

  static String categoryLabel(String category) {
    return '${categoryEmoji(category)} $category';
  }

  static String filterCategoryLabel(String category) {
    if (category == 'ทั้งหมด') return category;
    return categoryLabel(category);
  }

  /// หมวดที่ควรตั้งความสำคัญสูงโดยค่าเริ่มต้น
  static bool isHighPriorityCategory(String category) {
    return category.contains('พ.ร.บ.') ||
        category.contains('ใบขับขี่') ||
        category.contains('ภาษีรถ') ||
        category == 'นัดราชการ';
  }

  static Widget backButton({
    required VoidCallback onPressed,
    String label = 'กลับ',
  }) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: IconButton(
        tooltip: label,
        icon: const Icon(Icons.arrow_back),
        onPressed: onPressed,
      ),
    );
  }

  static Widget labeledButton({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: child,
    );
  }
}
