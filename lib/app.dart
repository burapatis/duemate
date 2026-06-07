import 'package:flutter/material.dart';

import 'features/onboarding/app_launch_gate.dart';
import 'services/due_mate_services.dart';
import 'theme/app_theme.dart';

class DueMateApp extends StatefulWidget {
  DueMateApp({super.key, DueMateServices? services})
      : services = services ?? DueMateServices();

  final DueMateServices services;

  @override
  State<DueMateApp> createState() => _DueMateAppState();
}

class _DueMateAppState extends State<DueMateApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await widget.services.preferences.loadThemeMode();
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
    });
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DueMate',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: AppLaunchGate(
        services: widget.services,
        onThemeModeChanged: _onThemeModeChanged,
      ),
    );
  }
}
