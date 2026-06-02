import 'package:flutter/material.dart';

import 'features/home/home_dashboard_page.dart';
import 'services/due_mate_services.dart';
import 'theme/app_theme.dart';

class DueMateApp extends StatelessWidget {
  DueMateApp({super.key, DueMateServices? services})
      : services = services ?? DueMateServices();

  /// บริการกลาง — สร้างครั้งเดียวต่อการรันแอป
  final DueMateServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DueMate',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeDashboardPage(services: services),
    );
  }
}
