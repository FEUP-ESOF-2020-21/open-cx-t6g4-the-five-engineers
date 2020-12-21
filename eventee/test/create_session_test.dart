
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventee/view/create_session.dart';

void main() {
  MaterialApp app;

  setUpAll(() {
    app = MaterialApp(
      title: 'Eventee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CreateSession(),
    );
  });

  void testLimitedAttendanceInvalidInput(WidgetTester tester, String input) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(app);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Limited attendance'));
    await tester.pump();

    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.decoration.labelText == 'Limit'), '-20');

    // Tap the create button and trigger a frame
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    final finder = find.byType(AlertDialog);

    // Verify that an alert dialog has been displayed
    expect(finder, findsOneWidget);

    final dialog = finder.evaluate().first.widget as AlertDialog;
    final dialogContent = dialog.content as Text;

    assert(dialogContent.data.contains('Invalid attendance limit!'));
  }

  testWidgets('Negative limited attendance', (WidgetTester tester) async {
    testLimitedAttendanceInvalidInput(tester, '-20');
  });

  testWidgets('Float limited attendance', (WidgetTester tester) async {
    testLimitedAttendanceInvalidInput(tester, '102.22');
  });

  testWidgets('Zero limited attendance', (WidgetTester tester) async {
    testLimitedAttendanceInvalidInput(tester, '0');
  });

  testWidgets('Text limited attendance', (WidgetTester tester) async {
    testLimitedAttendanceInvalidInput(tester, 'Some text');
  });
}