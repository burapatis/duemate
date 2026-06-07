import 'package:flutter/material.dart';

import '../../theme/app_branding.dart';
import '../home/reminder_ui.dart';
import 'onboarding_content.dart';

/// ข้อตกลงและเงื่อนไข — ครั้งแรกต้องยืนยันก่อนใช้งาน
class TermsOfUsePage extends StatefulWidget {
  const TermsOfUsePage({
    super.key,
    required this.onAccepted,
    this.isOnboarding = true,
  });

  final Future<void> Function() onAccepted;
  final bool isOnboarding;

  @override
  State<TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  bool _hasReadAgreement = false;

  Future<void> _accept() async {
    await widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isOnboarding,
        leading: widget.isOnboarding
            ? null
            : ReminderUi.backButton(
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        title: const Text(OnboardingContent.termsTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ReminderUi.pagePadding),
              children: [
                Text(
                  'กรุณาอ่านข้อตกลงก่อนเริ่มใช้งาน ${AppBranding.displayNameTh}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: ReminderUi.blockGap),
                ...OnboardingContent.termsSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ReminderUi.sectionGap),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(ReminderUi.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            ...section.bullets.map(
                              (bullet) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(bullet)),
                                  ],
                                ),
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
          if (widget.isOnboarding)
            SafeArea(
              minimum: const EdgeInsets.all(ReminderUi.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hasReadAgreement,
                    onChanged: (value) {
                      setState(() {
                        _hasReadAgreement = value ?? false;
                      });
                    },
                    title: const Text('ฉันได้อ่านและยอมรับข้อตกลงนี้'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _hasReadAgreement ? _accept : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('ยืนยันการใช้งาน'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
