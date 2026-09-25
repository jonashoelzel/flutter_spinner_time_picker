import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const spinnerOptions = RawNumberSpinnerOptions(
    height: 130,
    width: 80,
    digitHeight: 40,
    selectedTextStyle: TextStyle(fontSize: 24),
    nonSelectedTextStyle: TextStyle(fontSize: 24),
    spinnerBgColor: Colors.white,
    padNumbers: false,
    enableHapticFeedback: false,
    showInfinityBetweenSmallestAndLargestValue: true,
  );

  testWidgets('minimum one skips zero and keeps stepped values and infinity',
      (tester) async {
    int? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SpinnerNumberPicker(
            initValue: 1,
            minValue: 1,
            maxValue: 61,
            steps: 20,
            options: const SpinnerNumberPickerOptions(
              spinnerOptions: spinnerOptions,
              elementsSpace: 0,
            ),
            onChangedSelectedValue: (value) => selected = value,
          ),
        ),
      ),
    ));

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(selected, 20);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('∞'), findsOneWidget);
  });
}
