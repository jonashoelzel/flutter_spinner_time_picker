import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nests one [MaterialApp] inside another so the root navigator and the nearest
/// navigator are two different objects, which is how the pickers are used when
/// a host app is embedded — under Widgetbook, for instance.
///
/// [show] is invoked with a context below the inner app.
Future<void> _pumpNested(
  WidgetTester tester,
  Future<void> Function(BuildContext context) show,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MaterialApp(
        key: const Key('inner-app'),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('useRootNavigator', () {
    testWidgets('number picker defaults to the nearest navigator', (
      tester,
    ) async {
      await _pumpNested(
        tester,
        (context) => showSpinnerNumberPicker(context, initValue: 5),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('inner-app')),
          matching: find.byType(AlertDialog),
        ),
        findsOneWidget,
        reason: 'the dialog belongs to the navigator it was opened from',
      );
    });

    testWidgets('number picker honours useRootNavigator: true', (tester) async {
      await _pumpNested(
        tester,
        (context) => showSpinnerNumberPicker(
          context,
          initValue: 5,
          useRootNavigator: true,
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('inner-app')),
          matching: find.byType(AlertDialog),
        ),
        findsNothing,
        reason: 'the dialog was pushed above the inner app',
      );
    });

    testWidgets('duration picker defaults to the nearest navigator', (
      tester,
    ) async {
      await _pumpNested(
        tester,
        (context) => showSpinnerDurationPicker(context),
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('inner-app')),
          matching: find.byType(AlertDialog),
        ),
        findsOneWidget,
      );
    });

    testWidgets('time picker defaults to the nearest navigator', (
      tester,
    ) async {
      await _pumpNested(tester, (context) => showSpinnerTimePicker(context));

      expect(
        find.descendant(
          of: find.byKey(const Key('inner-app')),
          matching: find.byType(AlertDialog),
        ),
        findsOneWidget,
      );
    });
  });
}
