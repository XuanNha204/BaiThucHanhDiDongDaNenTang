import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:may_tinh_co_ban/main.dart';

void main() {
  String getDisplayText(WidgetTester tester) {
    final textWidget = tester.widget<Text>(find.byKey(const Key('display_text')));
    return textWidget.data ?? '';
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(ElevatedButton, label));
    await tester.pump();
  }

  testWidgets('student label and operator precedence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('2224801030048'), findsOneWidget);

    await tapButton(tester, '7');
    await tapButton(tester, '+');
    await tapButton(tester, '8');
    await tapButton(tester, '×');
    await tapButton(tester, '2');
    await tapButton(tester, '=');

    expect(getDisplayText(tester), '23');
  });

  testWidgets('supports decimal values', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '1');
    await tapButton(tester, ',');
    await tapButton(tester, '5');
    await tapButton(tester, '+');
    await tapButton(tester, '2');
    await tapButton(tester, '=');

    expect(getDisplayText(tester), '3,5');
  });

  testWidgets('supports square function (x²)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '5');
    await tapButton(tester, 'x²');

    expect(getDisplayText(tester), '25');
  });

  testWidgets('supports square root function (√x)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '9');
    await tapButton(tester, '√x');

    expect(getDisplayText(tester), '3');
  });

  testWidgets('supports reciprocal (¹/x) and percentage (%)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '4');
    await tapButton(tester, '¹/x');

    expect(getDisplayText(tester), '0,25');

    await tapButton(tester, 'C');

    await tapButton(tester, '5');
    await tapButton(tester, '0');
    await tapButton(tester, '%');

    expect(getDisplayText(tester), '0,5');
  });

  testWidgets('supports toggle sign (+/-)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '8');
    await tapButton(tester, '+/-');

    expect(getDisplayText(tester), '-8');

    await tapButton(tester, '+/-');

    expect(getDisplayText(tester), '8');
  });

  testWidgets('supports Clear Entry (CE) and backspace (⌫)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '1');
    await tapButton(tester, '2');
    await tapButton(tester, '+');
    await tapButton(tester, '9');
    await tapButton(tester, 'CE');
    await tapButton(tester, '5');
    await tapButton(tester, '=');

    expect(getDisplayText(tester), '17');

    // Backspace test
    await tapButton(tester, '8');
    await tapButton(tester, '9');
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(getDisplayText(tester), '8');
  });

  testWidgets('saves and shows calculation history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tapButton(tester, '9');
    await tapButton(tester, '+');
    await tapButton(tester, '6');
    await tapButton(tester, '=');

    expect(getDisplayText(tester), '15');

    // Open history sheet
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text('Lịch sử tính toán'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '9+6 ='), findsOneWidget);

    // Tap on history item to recall
    await tester.tap(find.widgetWithText(ListTile, '9+6 ='));
    await tester.pumpAndSettle();

    expect(getDisplayText(tester), '15');
  });

  testWidgets('supports memory operations (MS, M+, M-)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Enter 10 and store in memory (MS)
    await tapButton(tester, '1');
    await tapButton(tester, '0');
    await tester.tap(find.text('MS'));
    await tester.pump();

    // Enter 5 and M+ (memory becomes 15)
    await tapButton(tester, 'C');
    await tapButton(tester, '5');
    await tester.tap(find.text('M+'));
    await tester.pump();

    // Enter 3 and M- (memory becomes 12)
    await tapButton(tester, 'C');
    await tapButton(tester, '3');
    await tester.tap(find.text('M-'));
    await tester.pump();

    expect(find.textContaining('12'), findsWidgets);
  });
}
