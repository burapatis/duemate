import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:duemate/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('แสดงหน้าแดชบอร์ดภาษาไทย', (WidgetTester tester) async {
    await tester.pumpWidget(const DueMateApp());
    await tester.pumpAndSettle();

    expect(find.text('DueMate'), findsOneWidget);
    expect(find.text('รายการเอกสารของคุณ'), findsOneWidget);
    expect(find.text('วันนี้'), findsOneWidget);
  });
}
