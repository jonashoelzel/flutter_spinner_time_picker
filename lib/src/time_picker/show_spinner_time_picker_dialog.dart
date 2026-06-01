// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

// Import custom widget used in the dialog
import 'spinner_time_picker_widget.dart';

class SpinnerTimePickerDialogOptions {
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
  /// layout always fits regardless of 12h/24h format, locale or text scale.
  /// Provide a value only to force a fixed width.
  final double? width;
  final EdgeInsets? contentPadding;
  final String cancelButtonLabel;
  final String okButtonLabel;
  final String nowButtonLabel;
  final bool showNowButton;
  final SpinnerTimePickerOptions pickerOptions;

  const SpinnerTimePickerDialogOptions({
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
    required this.nowButtonLabel,
    required this.showNowButton,
    required this.pickerOptions,
  });

  factory SpinnerTimePickerDialogOptions.fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SpinnerTimePickerDialogOptions(
      title: "Select a Time",
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
      nowButtonLabel: "Now",
      showNowButton: false,
      pickerOptions: SpinnerTimePickerOptions.fromContext(context),
    );
  }

  SpinnerTimePickerDialogOptions copyWith({
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
    String? nowButtonLabel,
    bool? showNowButton,
    SpinnerTimePickerOptions? pickerOptions,
  }) {
    return SpinnerTimePickerDialogOptions(
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
      nowButtonLabel: nowButtonLabel ?? this.nowButtonLabel,
      showNowButton: showNowButton ?? this.showNowButton,
      pickerOptions: pickerOptions ?? this.pickerOptions,
    );
  }
}

// Function to show a dialog with a spinner-based time picker
Future<TimeOfDay?> showSpinnerTimePicker(
  BuildContext context, {
  TimeOfDay? initTime,
  bool barrierDismissible = true,
  bool useRootNavigator = false,
  SpinnerTimePickerDialogOptions? options,
}) async {
  final effectiveOptions =
      options ?? SpinnerTimePickerDialogOptions.fromContext(context);

  // Initialize selectedTime variable
  TimeOfDay selectedTime = initTime ?? TimeOfDay.now();

  // Show the dialog and get the selected time when the dialog is dismissed
  return showDialog<TimeOfDay?>(
    context: context,
    useRootNavigator: useRootNavigator,
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
            child: SpinnerTimePicker(
              initTime: selectedTime,
              options: effectiveOptions.pickerOptions,
              onChangedSelectedTime: (time) {
                selectedTime = time;
              },
            ),
          ),
          actions: [
            if (effectiveOptions.showNowButton)
              TextButton(
                style: effectiveOptions.buttonStyle,
                onPressed: () => Navigator.of(context).pop(TimeOfDay.now()),
                child: Text(effectiveOptions.nowButtonLabel,
                    style: effectiveOptions.buttonTextStyle),
              ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(initTime),
              child: Text(effectiveOptions.cancelButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(selectedTime),
              child: Text(effectiveOptions.okButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
          ],
        ),
      );
    },
  );
}
