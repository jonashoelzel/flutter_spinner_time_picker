import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const longHint =
      'A hint that is much too long to fit on a single line of this dialog, '
      'so it has to wrap to the width of the wheels instead of widening it.';

  Duration? result;

  Future<void> openPicker(
    WidgetTester tester, {
    Widget? Function(BuildContext, Duration)? hintBuilder,
  }) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showSpinnerDurationPicker(
                  context,
                  initDuration: const Duration(seconds: 30),
                  options: SpinnerDurationPickerDialogOptions.fromContext(
                    context,
                  ).copyWith(hintBuilder: hintBuilder),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  /// Scrolls the seconds wheel, the last one, up by a few values.
  Future<void> scrollSeconds(WidgetTester tester) async {
    await tester.drag(
        find.byType(ListWheelScrollView).last, const Offset(0, -120));
    await tester.pumpAndSettle();
  }

  testWidgets('the hint follows the wheels while the dialog is open', (
    tester,
  ) async {
    await openPicker(
      tester,
      hintBuilder: (_, selected) => selected > const Duration(seconds: 30)
          ? const Text('Too long')
          : null,
    );
    expect(find.text('Too long'), findsNothing);

    await scrollSeconds(tester);

    expect(find.text('Too long'), findsOneWidget);
  });

  testWidgets('the hint gets the value the wheels open with', (tester) async {
    Duration? seen;
    await openPicker(
      tester,
      hintBuilder: (_, selected) {
        seen = selected;
        return null;
      },
    );

    expect(seen, const Duration(seconds: 30));
  });

  testWidgets('Done still returns the picked value with a hint', (
    tester,
  ) async {
    await openPicker(tester, hintBuilder: (_, __) => const Text('Hint'));
    await scrollSeconds(tester);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result, greaterThan(const Duration(seconds: 30)));
  });

  testWidgets('a long hint wraps instead of widening the dialog', (
    tester,
  ) async {
    await openPicker(tester);
    final plainWidth = tester.getSize(find.byType(AlertDialog)).width;
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await openPicker(tester, hintBuilder: (_, __) => const Text(longHint));

    expect(tester.getSize(find.byType(AlertDialog)).width, plainWidth);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a null hint leaves the dialog as it is without a builder', (
    tester,
  ) async {
    await openPicker(tester);
    final plain = tester.getSize(find.byType(AlertDialog));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await openPicker(tester, hintBuilder: (_, __) => null);

    expect(tester.getSize(find.byType(AlertDialog)), plain);
  });
}
