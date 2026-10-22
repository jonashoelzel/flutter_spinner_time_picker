import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const apertures = ['f/2.8', 'f/4', 'f/5.6', 'f/8', 'f/11'];

  final spinnerOptions = RawNumberSpinnerOptions(
    height: 130,
    width: 40,
    digitHeight: 40,
    selectedTextStyle: const TextStyle(fontSize: 24),
    nonSelectedTextStyle: const TextStyle(fontSize: 24),
    spinnerBgColor: Colors.white,
    enableHapticFeedback: false,
    labelBuilder: (value) => apertures[value],
  );

  testWidgets('labelBuilder replaces the numbers and keeps the index value', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SpinnerNumberPicker(
              initValue: 2,
              maxValue: apertures.length,
              options: SpinnerNumberPickerOptions(
                spinnerOptions: spinnerOptions,
                elementsSpace: 0,
              ),
              onChangedSelectedValue: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('f/5.6'), findsOneWidget);
    expect(find.text('2'), findsNothing);

    await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(selected, 3);
  });

  test('box width fits the widest label', () {
    final width = resolveSpinnerBoxWidth(
      options: spinnerOptions,
      largestValue: apertures.length - 1,
      textScaler: TextScaler.noScaling,
      labels: apertures,
    );
    final digitWidth = resolveSpinnerBoxWidth(
      options: spinnerOptions,
      largestValue: apertures.length - 1,
      textScaler: TextScaler.noScaling,
    );
    expect(width, greaterThan(digitWidth));
  });
}
