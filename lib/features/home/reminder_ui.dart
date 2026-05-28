import 'package:flutter/material.dart';

class ReminderUi {
  static IconData categoryIcon(String category) {
    switch (category) {
      case 'รถ':
        return Icons.directions_car_filled_rounded;
      case 'บ้าน':
        return Icons.home_rounded;
      case 'ส่วนตัว':
        return Icons.person_rounded;
      case 'ครอบครัว':
        return Icons.family_restroom_rounded;
      case 'สินค้า/รับประกัน':
        return Icons.verified_user_rounded;
      case 'งาน/ราชการ':
        return Icons.account_balance_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  static String categoryEmoji(String category) {
    switch (category) {
      case 'รถ':
        return '🚗';
      case 'บ้าน':
        return '🏠';
      case 'ส่วนตัว':
        return '👤';
      case 'ครอบครัว':
        return '👨‍👩‍👧‍👦';
      case 'สินค้า/รับประกัน':
        return '🛡️';
      case 'งาน/ราชการ':
        return '🏛️';
      default:
        return '📄';
    }
  }
}
