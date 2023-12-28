// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';

import '../spinner_numeric_picker_widget.dart';

class SpinnerNumberPicker extends StatelessWidget {
  final AlwaysChangeValueNotifier<int> _forceUpdateValueNotifier;
  final int maxValue; // Maximum value of the picker
  final int steps; // Steps for the picker
  final double spinnerHeight; // Height of the widget
  final double spinnerWidth; // Width of the widget
  final double elementsSpace; // Space between hour and minute pickers
  final double digitHeight; // Height of individual number elements
  final Color spinnerBgColor; // Background color of the widget
  final TextStyle selectedTextStyle; // Text style for selected number elements
  final TextStyle
      nonSelectedTextStyle; // Text style for non-selected number elements
  final void Function(int selected) onChangedSelectedValue;
  final String? unit;
  final bool padNumbers;

  SpinnerNumberPicker({
    AlwaysChangeValueNotifier<int>? forceUpdateValueNotifier,
    int? initValue,
    required this.maxValue,
    this.steps = 1,
    required this.spinnerHeight,
    required this.spinnerWidth,
    required this.elementsSpace,
    required this.digitHeight,
    required this.spinnerBgColor,
    required this.selectedTextStyle,
    required this.nonSelectedTextStyle,
    required this.onChangedSelectedValue,
    this.padNumbers = false,
    this.unit,
    super.key,
  })  : assert(
            (initValue != null || forceUpdateValueNotifier != null) &&
                (initValue == null || forceUpdateValueNotifier == null),
            'Either initValue xor forceValueChangeNotifier must be provided'),
        _forceUpdateValueNotifier = forceUpdateValueNotifier ??
            AlwaysChangeValueNotifier<int>(initValue!);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        SpinnerNumericPicker(
          forceUpdateValueNotifier: _forceUpdateValueNotifier,
          maxValue: maxValue,
          steps: steps,
          height: spinnerHeight,
          width: spinnerWidth,
          digitHeight: digitHeight,
          nonSelectedTextStyle: nonSelectedTextStyle,
          selectedTextStyle: selectedTextStyle,
          spinnerBgColor: spinnerBgColor,
          onSelectedItemChanged: onChangedSelectedValue,
          padNumbers: padNumbers,
        ),
        unit == null
            ? const SizedBox()
            : SizedBox(
                width: elementsSpace,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 0.15 * elementsSpace),
                    Text(
                      unit!,
                      style: TextStyle(
                          fontSize: 23,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
