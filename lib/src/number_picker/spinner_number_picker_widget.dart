// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';

import '../raw_number_spinner.dart';

class SpinnerNumberPickerOptions {
  final RawNumberSpinnerOptions spinnerOptions;
  final double elementsSpace;
  final String? unit;
  final TextStyle? unitTextStyle;

  const SpinnerNumberPickerOptions({
    required this.spinnerOptions,
    required this.elementsSpace,
    this.unit,
    this.unitTextStyle,
  });

  factory SpinnerNumberPickerOptions.fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SpinnerNumberPickerOptions(
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context),
      elementsSpace: 0.08 * (0.85 * size.width),
      unitTextStyle: TextStyle(
        fontSize: 23,
        color: colorScheme.primary,
      ),
    );
  }

  SpinnerNumberPickerOptions copyWith({
    RawNumberSpinnerOptions? spinnerOptions,
    double? elementsSpace,
    String? unit,
    TextStyle? unitTextStyle,
  }) {
    return SpinnerNumberPickerOptions(
      spinnerOptions: spinnerOptions ?? this.spinnerOptions,
      elementsSpace: elementsSpace ?? this.elementsSpace,
      unit: unit ?? this.unit,
      unitTextStyle: unitTextStyle ?? this.unitTextStyle,
    );
  }
}

class SpinnerNumberPicker extends StatelessWidget {
  final AlwaysChangeValueNotifier<int> _forceUpdateValueNotifier;
  final int maxValue;
  final int steps;
  final SpinnerNumberPickerOptions options;
  final void Function(int selected) onChangedSelectedValue;

  SpinnerNumberPicker({
    AlwaysChangeValueNotifier<int>? forceUpdateValueNotifier,
    int? initValue,
    required this.maxValue,
    required this.options,
    required this.onChangedSelectedValue,
    this.steps = 1,
    super.key,
  })  : assert(
          (initValue != null || forceUpdateValueNotifier != null) &&
              (initValue == null || forceUpdateValueNotifier == null),
          'Either initValue xor forceValueChangeNotifier must be provided',
        ),
        _forceUpdateValueNotifier = forceUpdateValueNotifier ??
            AlwaysChangeValueNotifier<int>(
              initValue == -1 ? maxValue : initValue!,
            );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        RawNumberSpinner(
          forceUpdateValueNotifier: _forceUpdateValueNotifier,
          maxValue: maxValue,
          steps: steps,
          options: options.spinnerOptions,
          onSelectedItemChanged: onChangedSelectedValue,
        ),
        options.unit == null
            ? const SizedBox()
            : SizedBox(
                width: options.elementsSpace,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 0.15 * options.elementsSpace),
                    Text(
                      options.unit!,
                      style: options.unitTextStyle ??
                          TextStyle(
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
