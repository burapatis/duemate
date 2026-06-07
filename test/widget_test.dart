import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:duemate/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'duemate_accepted_terms': true,
      'duemate_completed_usage_guide': true,
    });
  });

  testWidgets('แสดงหน้าแดชบอร์ดภาษาไทย', (WidgetTester tester) async {
    await tester.pumpWidget(DueMateApp());
    await tester.pumpAndSettle();

    expect(find.text('DueMate'), findsOneWidget);
    expect(find.text('สรุปเอกสาร'), findsOneWidget);
    expect(find.text('รายการเอกสารสำคัญ'), findsOneWidget);
    expect(find.text('หน้าหลัก'), findsOneWidget);
  });
}
