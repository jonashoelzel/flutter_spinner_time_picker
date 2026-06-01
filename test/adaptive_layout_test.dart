import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders [child] inside a [SizedBox] that is deliberately far narrower than
/// the picker's natural width, so any fixed-width layout would overflow.
Future<void> _pumpInNarrowBox(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 120,
            height: 200,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  // A spinner config whose intrinsic width is much larger than the 120px box
  // it is rendered in, to force the adaptive layout to scale down.
  const spinnerOptions = RawNumberSpinnerOptions(
    height: 130,
    width: 90,
    digitHeight: 40,
    selectedTextStyle: TextStyle(fontSize: 30),
    nonSelectedTextStyle: TextStyle(fontSize: 30),
    spinnerBgColor: Color(0xFFEEEEEE),
  );

  testWidgets('12-hour time picker does not overflow in a narrow box',
      (tester) async {
    await _pumpInNarrowBox(
      tester,
      SpinnerTimePicker(
        initTime: const TimeOfDay(hour: 13, minute: 34),
        onChangedSelectedTime: (_) {},
        options: const SpinnerTimePickerOptions(
          spinnerOptions: spinnerOptions,
          elementsSpace: 40,
          is24HourFormat: false,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('24-hour time picker does not overflow in a narrow box',
      (tester) async {
    await _pumpInNarrowBox(
      tester,
      SpinnerTimePicker(
        initTime: const TimeOfDay(hour: 13, minute: 34),
        onChangedSelectedTime: (_) {},
        options: const SpinnerTimePickerOptions(
          spinnerOptions: spinnerOptions,
          elementsSpace: 40,
          is24HourFormat: true,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('duration picker (h/m/s) does not overflow in a narrow box',
      (tester) async {
    await _pumpInNarrowBox(
      tester,
      SpinnerDurationPicker(
        initDuration: const Duration(hours: 1, minutes: 2, seconds: 3),
        onChangedSelectedDuration: (_) {},
        options: const SpinnerDurationPickerOptions(
          spinnerOptions: spinnerOptions,
          elementsSpace: 40,
          hideSeconds: false,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('spinner box grows beyond its width floor to pad a large font',
      (tester) async {
    const widthFloor = 38.0;
    final largeFontOptions = spinnerOptions.copyWith(
      width: widthFloor,
      selectedTextStyle: const TextStyle(fontSize: 44),
    );

    final boxWidth = resolveSpinnerBoxWidth(
      options: largeFontOptions,
      largestValue: 59,
      textScaler: TextScaler.noScaling,
    );

    // The two-digit "59" at 44px plus font-proportional padding is wider than
    // the 38px floor, so the coloured box grows to keep breathing room.
    expect(boxWidth, greaterThan(widthFloor));
  });

  testWidgets('number picker with a unit does not overflow in a narrow box',
      (tester) async {
    await _pumpInNarrowBox(
      tester,
      SpinnerNumberPicker(
        initValue: 42,
        maxValue: 100,
        onChangedSelectedValue: (_) {},
        options: const SpinnerNumberPickerOptions(
          spinnerOptions: spinnerOptions,
          elementsSpace: 40,
          unit: 'shots',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
