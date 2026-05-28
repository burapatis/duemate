import 'package:flutter_test/flutter_test.dart';

import 'package:duemate/app.dart';

void main() {
  testWidgets('แสดงหน้าแดชบอร์ดภาษาไทย', (WidgetTester tester) async {
    await tester.pumpWidget(const DueMateApp());

    expect(find.text('DueMate'), findsOneWidget);
    expect(find.text('งานใกล้ครบกำหนด'), findsOneWidget);
    expect(find.text('งานวันนี้'), findsOneWidget);
  });
}
