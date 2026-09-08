import 'package:flutter_test/flutter_test.dart';

import 'package:may_tinh_co_ban/main.dart';

void main() {
  testWidgets('student label and operator precedence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('2224801030048'), findsOneWidget);

    await tester.tap(find.text('7'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('8'));
    await tester.tap(find.text('\u00D7'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('23'), findsOneWidget);
  });

  testWidgets('supports decimal values', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('1'));
    await tester.tap(find.text(','));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('3,5'), findsOneWidget);
  });
}
