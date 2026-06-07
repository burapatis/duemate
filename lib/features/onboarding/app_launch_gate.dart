import 'package:flutter/material.dart';

import '../../services/due_mate_services.dart';
import '../home/home_dashboard_page.dart';
import 'terms_of_use_page.dart';
import 'usage_guide_page.dart';

enum _LaunchStep { loading, terms, guide, home }

/// ตรวจขั้นตอนแรกเข้าใช้งาน — ข้อตกลง → วิธีใช้ → หน้าหลัก
class AppLaunchGate extends StatefulWidget {
  const AppLaunchGate({
    super.key,
    required this.services,
    required this.onThemeModeChanged,
  });

  final DueMateServices services;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppLaunchGate> createState() => _AppLaunchGateState();
}

class _AppLaunchGateState extends State<AppLaunchGate> {
  _LaunchStep _step = _LaunchStep.loading;

  @override
  void initState() {
    super.initState();
    _resolveLaunchStep();
  }

  Future<void> _resolveLaunchStep() async {
    final prefs = widget.services.preferences;
    final acceptedTerms = await prefs.hasAcceptedTerms();
    final completedGuide = await prefs.hasCompletedUsageGuide();

    if (!mounted) return;

    setState(() {
      if (!acceptedTerms) {
        _step = _LaunchStep.terms;
      } else if (!completedGuide) {
        _step = _LaunchStep.guide;
      } else {
        _step = _LaunchStep.home;
      }
    });
  }

  Future<void> _onTermsAccepted() async {
    await widget.services.preferences.setAcceptedTerms(true);
    if (!mounted) return;
    setState(() {
      _step = _LaunchStep.guide;
    });
  }

  Future<void> _onGuideCompleted() async {
    await widget.services.preferences.setCompletedUsageGuide(true);
    if (!mounted) return;
    setState(() {
      _step = _LaunchStep.home;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _LaunchStep.loading => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('กำลังเตรียมแอป...'),
              ],
            ),
          ),
        ),
      _LaunchStep.terms => TermsOfUsePage(
          isOnboarding: true,
          onAccepted: _onTermsAccepted,
        ),
      _LaunchStep.guide => UsageGuidePage(
          isOnboarding: true,
          onCompleted: _onGuideCompleted,
        ),
      _LaunchStep.home => HomeDashboardPage(
          services: widget.services,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
    };
  }
}
