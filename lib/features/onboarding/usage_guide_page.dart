import 'package:flutter/material.dart';

import '../../theme/app_branding.dart';
import '../home/reminder_ui.dart';
import 'onboarding_content.dart';

/// วิธีใช้งานอย่างง่าย — แสดงหลังยอมรับข้อตกลง (ครั้งแรก)
class UsageGuidePage extends StatelessWidget {
  const UsageGuidePage({
    super.key,
    required this.onCompleted,
    this.isOnboarding = true,
  });

  final Future<void> Function() onCompleted;
  final bool isOnboarding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isOnboarding,
        leading: isOnboarding
            ? null
            : ReminderUi.backButton(
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        title: const Text(OnboardingContent.usageGuideTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ReminderUi.pagePadding),
              children: [
                Text(
                  'เริ่มใช้ ${AppBranding.displayNameTh} ได้ใน 5 ขั้นตอนนี้',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: ReminderUi.blockGap),
                ...OnboardingContent.usageSteps.asMap().entries.map((entry) {
                  final step = entry.value;
                  final stepNo = entry.key + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: ReminderUi.sectionGap),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(ReminderUi.cardPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$stepNo. ${step.title}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(step.detail),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (isOnboarding)
            SafeArea(
              minimum: const EdgeInsets.all(ReminderUi.pagePadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => onCompleted(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('รับทราบ พร้อมเข้าใช้งาน'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
