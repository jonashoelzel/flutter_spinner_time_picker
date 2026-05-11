// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
export 'spinner_duration_picker_widget.dart' show INFINITY_DURATION;

// Import custom widget used in the dialog
import 'spinner_duration_picker_widget.dart';

class SpinnerDurationPickerDialogOptions {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle titleStyle;
  final ButtonStyle? buttonStyle;
  final TextStyle buttonTextStyle;
  final double height;
  final double width;
  final EdgeInsets? contentPadding;
  final String cancelButtonLabel;
  final String okButtonLabel;
  final String infinityButtonLabel;
  final bool showInfinityButton;
  final SpinnerDurationPickerOptions pickerOptions;

  const SpinnerDurationPickerDialogOptions({
    required this.title,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.titleStyle,
    this.buttonStyle,
    required this.buttonTextStyle,
    required this.height,
    required this.width,
    this.contentPadding,
    required this.cancelButtonLabel,
    required this.okButtonLabel,
    required this.infinityButtonLabel,
    required this.showInfinityButton,
    required this.pickerOptions,
  });

  factory SpinnerDurationPickerDialogOptions.fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SpinnerDurationPickerDialogOptions(
      title: "Select a Duration",
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
      width: 0.85 * size.width,
      cancelButtonLabel: 'Cancel',
      okButtonLabel: "Done",
      infinityButtonLabel: "Infinite",
      showInfinityButton: false,
      pickerOptions: SpinnerDurationPickerOptions.fromContext(context),
    );
  }

  SpinnerDurationPickerDialogOptions copyWith({
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
    SpinnerDurationPickerOptions? pickerOptions,
  }) {
    return SpinnerDurationPickerDialogOptions(
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

// Function to show a dialog with a spinner-based duration picker
Future<Duration?> showSpinnerDurationPicker(
  BuildContext context, {
  Duration? initDuration,
  bool barrierDismissible = true,
  bool useRootNavigator = false,
  SpinnerDurationPickerDialogOptions? options,
}) async {
  final effectiveOptions =
      options ?? SpinnerDurationPickerDialogOptions.fromContext(context);

  // Initialize selectedDuration variable
  Duration selectedDuration = initDuration ?? Duration.zero;

  // Show the dialog and get the selected duration when the dialog is dismissed
  return showDialog<Duration?>(
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
            child: SpinnerDurationPicker(
              initDuration: selectedDuration,
              options: effectiveOptions.pickerOptions,
              onChangedSelectedDuration: (duration) {
                selectedDuration = duration;
              },
            ),
          ),
          actions: [
            if (effectiveOptions.showInfinityButton)
              TextButton(
                style: effectiveOptions.buttonStyle,
                onPressed: () => Navigator.of(context).pop(INFINITY_DURATION),
                child: Text(effectiveOptions.infinityButtonLabel,
                    style: effectiveOptions.buttonTextStyle),
              ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(initDuration),
              child: Text(effectiveOptions.cancelButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
            TextButton(
              style: effectiveOptions.buttonStyle,
              onPressed: () => Navigator.of(context).pop(selectedDuration),
              child: Text(effectiveOptions.okButtonLabel,
                  style: effectiveOptions.buttonTextStyle),
            ),
          ],
        ),
      );
    },
  );
}
