import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final initialMs in [4390, 4340, 59990]) {
    for (final confirm in [true, false]) {
      testWidgets('$initialMs ms with untouched wheels, confirm=$confirm', (
        tester,
      ) async {
        var interval = Duration(milliseconds: initialMs);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    final result = await showSpinnerDurationPicker(
                      context,
                      initDuration: interval,
                      options: SpinnerDurationPickerDialogOptions.fromContext(
                        context,
                      ).copyWith(
                        okButtonLabel: 'Done',
                        cancelButtonLabel: 'Cancel',
                        pickerOptions: SpinnerDurationPickerOptions.fromContext(
                          context,
                        ).copyWith(hideMilliseconds: false),
                      ),
                    );
                    if (result != null) interval = result;
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(confirm ? 'Done' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(
          interval.inMilliseconds,
          confirm
              ? {4390: 4400, 4340: 4300, 59990: 60000}[initialMs]
              : initialMs,
        );
      });
    }
  }
}
