import 'package:flutter/material.dart';

import 'features/home/home_dashboard_page.dart';
import 'theme/app_theme.dart';

class DueMateApp extends StatelessWidget {
  const DueMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DueMate',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeDashboardPage(),
    );
  }
}
