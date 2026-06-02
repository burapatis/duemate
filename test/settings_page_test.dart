import 'package:duemate/features/settings/settings_page.dart';
import 'package:duemate/services/due_mate_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Settings มีส่วน beta แบบพับได้', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          services: DueMateServices(),
          onThemeModeChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ตั้งค่าและความเป็นส่วนตัว'), findsOneWidget);
    expect(find.text('รูปแบบหน้าจอ'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byType(ExpansionTile), findsNWidgets(2));
    expect(
      find.text('แตะเพื่อดูรายละเอียดสำหรับผู้ทดสอบ'),
      findsOneWidget,
    );
    expect(find.text('เพิ่มรายการเอกสาร'), findsNothing);
  });
}
