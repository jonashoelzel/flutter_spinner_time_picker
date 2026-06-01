// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

// Import custom widget used in the dialog
import 'spinner_number_picker_widget.dart';

class SpinnerNumberPickerDialogOptions {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle titleStyle;
  final ButtonStyle? buttonStyle;
  final TextStyle buttonTextStyle;
  final double height;

  /// Width of the dialog content.
  ///
  /// When `null` (the default) the content sizes itself to the picker's
  /// intrinsic width and is capped at the available dialog width, so the
  /// layout always fits regardless of the unit label, locale or text scale.
  /// Provide a value only to force a fixed width.
  final double? width;
  final EdgeInsets? contentPadding;
  final String cancelButtonLabel;
  final String okButtonLabel;
  final String infinityButtonLabel;
  final bool showInfinityButton;
  final SpinnerNumberPickerOptions pickerOptions;

  const SpinnerNumberPickerDialogOptions({
    required this.title,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.titleStyle,
    this.buttonStyle,
    required this.buttonTextStyle,
    required this.height,
    this.width,
    this.contentPadding,
    required this.cancelButtonLabel,
    required this.okButtonLabel,
    required this.infinityButtonLabel,
    required this.showInfinityButton,
    required this.pickerOptions,
  });

  factory SpinnerNumberPickerDialogOptions.fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SpinnerNumberPickerDialogOptions(
      title: "Select a Value",
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface.withAlpha(200),
      titleStyle:
          TextStyle(fontSize: 18, color: colorScheme.onSurface.withAlpha(200)),
      buttonTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      height: 0.25 * size.height,
      cancelButtonLabel: 'Cancel',
      okButtonLabel: "Done",
      infinityButtonLabel: "Infinity",
      showInfinityButton: false,
      pickerOptions: SpinnerNumberPickerOptions.fromContext(context),
    );
  }

  SpinnerNumberPickerDialogOptions copyWith({
    String? title,
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? titleStyle,
    ButtonStyle? buttonStyle,
    TextStyle? buttonTextStyle,
    double? height,
    double? width,
    EdgeInsets? contentPadding,
    String? cancelButtonLabel,
    String? okButtonLabel,
    String? infinityButtonLabel,
    bool? showInfinityButton,
    SpinnerNumberPickerOptions? pickerOptions,
  }) {
    return SpinnerNumberPickerDialogOptions(
      title: title ?? this.title,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      height: height ?? this.height,
      width: width ?? this.width,
      contentPadding: contentPadding ?? this.contentPadding,
      cancelButtonLabel: cancelButtonLabel ?? this.cancelButtonLabel,
      okButtonLabel: okButtonLabel ?? this.okButtonLabel,
      infinityButtonLabel: infinityButtonLabel ?? this.infinityButtonLabel,
      showInfinityButton: showInfinityButton ?? this.showInfinityButton,
      pickerOptions: pickerOptions ?? this.pickerOptions,
    );
  }
}

// Function to show a dialog with a spinner-based number picker
Future<int?> showSpinnerNumberPicker(
  BuildContext context, {
  int? initValue,
  int maxValue = 100,
  int steps = 1,
  bool barrierDismissible = true,
  SpinnerNumberPickerDialogOptions? options,
}) async {
  final effectiveOptions =
      options ?? SpinnerNumberPickerDialogOptions.fromContext(context);

  // Initialize selectedValue and pressedButton variables
  int selectedValue = initValue ?? 0;

  // Show the dialog and get the selected number when the dialog is dismissed
  return showDialog<int?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return Theme(
        data: Theme.of(context)
            .copyWith(dialogBackgroundColor: effectiveOptions.backgroundColor),
        child: AlertDialog(
          contentPadding: effectiveOptions.contentPadding,
          title: Center(
              child: Text(effectiveOptions.title,
                  style: effectiveOptions.titleStyle)),
          content: SizedBox(
            height: effectiveOptions.height,
            width: effectiveOptions.width,
            child: SpinnerNumberPicker(
              onChangedSelectedValue: (selected) {
                selectedValue = selected;
              },
              initValue: selectedValue,
              maxValue: maxValue,
              steps: steps,
              options: effectiveOptions.pickerOptions,
            ),
          ),
          actions: [
            if (effectiveOptions.showInfinityButton)
              TextButton(
                style: effectiveOptions.buttonStyle,
                onPressed: () => Navigator.of(context).pop(-1),
                child: Text(effectiveOptions.infinityButtonLabel,
                    style: effectiveOptions.buttonTextStyle),
              ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(initValue),
              child: Text(effectiveOptions.cancelButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(selectedValue),
              child: Text(effectiveOptions.okButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
          ],
        ),
      );
    },
  );
}
