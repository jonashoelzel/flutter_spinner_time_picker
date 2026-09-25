import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

const _spinnerOptions = RawNumberSpinnerOptions(
  height: 130,
  width: 50,
  digitHeight: 40,
  selectedTextStyle: TextStyle(fontSize: 30),
  nonSelectedTextStyle: TextStyle(fontSize: 30),
  spinnerBgColor: Color(0xFFEEEEEE),
);

Future<List<Duration>> _pumpPicker(
  WidgetTester tester, {
  required Duration initDuration,
  required bool showDays,
  int maxDays = 100,
}) async {
  final changes = <Duration>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SpinnerDurationPicker(
            initDuration: initDuration,
            onChangedSelectedDuration: changes.add,
            options: SpinnerDurationPickerOptions(
              spinnerOptions: _spinnerOptions,
              elementsSpace: 20,
              hideSeconds: true,
              showDays: showDays,
              maxDays: maxDays,
            ),
          ),
        ),
      ),
    ),
  );
  return changes;
}

/// The wheels in the order they appear, left to right.
List<RawNumberSpinner> _wheels(WidgetTester tester) {
  final finder = find.byType(RawNumberSpinner);
  final wheels = tester.widgetList<RawNumberSpinner>(finder).toList()
    ..sort(
      (a, b) => tester
          .getTopLeft(find.byWidget(a))
          .dx
          .compareTo(tester.getTopLeft(find.byWidget(b)).dx),
    );
  return wheels;
}

void main() {
  testWidgets('without showDays the hours wheel still counts up to 99', (
    tester,
  ) async {
    final changes = await _pumpPicker(
      tester,
      initDuration: const Duration(hours: 52),
      showDays: false,
    );

    final wheels = _wheels(tester);
    expect(wheels, hasLength(2));
    expect(wheels.first.maxValue, 100);
    expect(find.text('d'), findsNothing);

    // Re-selecting the minutes reports the duration the wheels hold.
    wheels.last.onSelectedItemChanged(0);
    expect(changes.last, const Duration(hours: 52));
  });

  testWidgets('showDays adds a days wheel and wraps hours at 23', (
    tester,
  ) async {
    final changes = await _pumpPicker(
      tester,
      initDuration: const Duration(days: 2, hours: 4, minutes: 30),
      showDays: true,
      maxDays: 49,
    );

    final wheels = _wheels(tester);
    expect(wheels, hasLength(3));
    final [days, hours, minutes] = wheels;
    expect(days.maxValue, 49);
    expect(hours.maxValue, 24);
    expect(find.text('d'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Re-selecting the minutes reports the split the wheels hold: 2 days and
    // 4 hours, not 52 hours.
    minutes.onSelectedItemChanged(30);
    expect(changes.last, const Duration(days: 2, hours: 4, minutes: 30));
  });

  testWidgets('turning the days wheel reports whole days on top', (
    tester,
  ) async {
    final changes = await _pumpPicker(
      tester,
      initDuration: const Duration(days: 2, hours: 4, minutes: 30),
      showDays: true,
    );

    final daysWheel = _wheels(tester).first;
    daysWheel.onSelectedItemChanged(5);
    expect(changes.last, const Duration(days: 5, hours: 4, minutes: 30));
  });

  testWidgets('confirming untouched wheels keeps a multi-day duration', (
    tester,
  ) async {
    var picked = const Duration(days: 30, hours: 23, minutes: 59);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final result = await showSpinnerDurationPicker(
                  context,
                  initDuration: picked,
                  options: SpinnerDurationPickerDialogOptions.fromContext(
                    context,
                  ).copyWith(
                    pickerOptions: SpinnerDurationPickerOptions.fromContext(
                      context,
                    ).copyWith(hideSeconds: true, showDays: true),
                  ),
                );
                if (result != null) picked = result;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(picked, const Duration(days: 30, hours: 23, minutes: 59));
  });
}
