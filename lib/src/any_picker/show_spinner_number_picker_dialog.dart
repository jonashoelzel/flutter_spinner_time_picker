// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

// Import custom widget used in the dialog
import 'spinner_number_picker_widget.dart';

// Function to show a dialog with a spinner-based number picker
Future<int?> showSpinnerNumberPicker(BuildContext context, {
  // Optional parameters for customizing the appearance and behavior of the dialog
  String? title,
  Color? backgroundColor,
  Color? foregroundColor,
  TextStyle? titleStyle,
  ButtonStyle? buttonStyle,
  TextStyle? buttonTextStyle,
  bool barrierDismissible = true,
  int? initValue,
  int maxValue = 100,
  int steps = 1,
  double? height,
  double? width,
  double? spinnerHeight,
  double? spinnerWidth,
  double? elementsSpace,
  double? digitHeight,
  Color? spinnerBgColor,
  TextStyle? selectedTextStyle,
  TextStyle? nonSelectedTextStyle,
  EdgeInsets? contentPadding,
  String? cancelButtonLabel,
  String? okButtonLabel,
  String? unit,
  TextStyle? unitTextStyle,
  bool padNumbers = false,
}) async {
  // Get the color scheme and screen size from the current theme
  final colorScheme = Theme
      .of(context)
      .colorScheme;
  final size = MediaQuery
      .of(context)
      .size;
  final Brightness currentBrightness =
      MediaQuery
          .of(context)
          .platformBrightness;

  // Check the current brightness mode
  final bool isDarkMode = currentBrightness == Brightness.dark;

  // Set default values for various optional parameters
  final _foregroundColor =
      foregroundColor ?? colorScheme.onBackground.withAlpha(200);
  final _backgroundColor = backgroundColor ?? colorScheme.background;
  final _title = title ?? "Select a Value";
  final _titleStyle =
      titleStyle ?? TextStyle(fontSize: 18, color: _foregroundColor);
  final _height = height ?? 0.25 * size.height;
  final _width = width ?? 0.85 * size.width;
  final _spinnerHeight = spinnerHeight ?? 0.7 * _height;
  final _spinnerWidth = spinnerWidth ?? 0.19 * _width;
  final _elementsSpace = elementsSpace ?? 0.08 * _width;
  final _digitHeight = digitHeight ?? 0.35 * _spinnerHeight;

  // Set spinner background color based on dark mode status
  final _spinnerBgColor = spinnerBgColor ??
      (isDarkMode ? colorScheme.primary : colorScheme.primaryContainer);

  // Set default text styles for selected and non-selected number elements
  final _selectedTextStyle = selectedTextStyle ??
      TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? colorScheme.primaryContainer : colorScheme.primary,
      );
  final _nonSelectedTextStyle = nonSelectedTextStyle ??
      TextStyle(
        fontSize: 30,
        color: isDarkMode
            ? colorScheme.primaryContainer.withAlpha(200)
            : colorScheme.primary.withAlpha(150),
      );

  // Set default text style for buttons
  final _buttonTextStyle = buttonTextStyle ?? TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: colorScheme.primary,
  );

  // Set default labels for cancel and done buttons
  final _cancelButtonLabel = cancelButtonLabel ?? 'Cancel';
  final _okButtonLabel = okButtonLabel ?? "Done";

  // Initialize selectedValue and pressedButton variables
  int selectedValue = initValue ?? 0;
  String pressedButton = "Cancel";

  // Create the Cancel and Done buttons with their respective actions
  final actionsButtons = <Widget>[
    TextButton(
      style: buttonStyle,
      onPressed: () {
        pressedButton = "Cancel";
        Navigator.of(context).pop();
      },
      child: Text(_cancelButtonLabel, style: _buttonTextStyle),
    ),
    TextButton(
      style: buttonStyle,
      onPressed: () {
        pressedButton = "Done";
        Navigator.of(context).pop();
      },
      child: Text(_okButtonLabel, style: _buttonTextStyle),
    ),
  ];

  // Show the dialog and get the selected number when the dialog is dismissed
  await showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return Theme(
        data:
        Theme.of(context).copyWith(dialogBackgroundColor: _backgroundColor),
        child: AlertDialog(
          contentPadding: contentPadding,
          title: Center(child: Text(_title, style: _titleStyle)),
          content: SizedBox(
            height: _height,
            width: _width,
            child: SpinnerNumberPicker(
              onChangedSelectedValue: (selected) {
                selectedValue = selected;
              },
              digitHeight: _digitHeight,
              elementsSpace: _elementsSpace,
              initValue: selectedValue,
              maxValue: maxValue,
              steps: steps,
              nonSelectedTextStyle: _nonSelectedTextStyle,
              selectedTextStyle: _selectedTextStyle,
              spinnerBgColor: _spinnerBgColor,
              spinnerHeight: _spinnerHeight,
              spinnerWidth: _spinnerWidth,
              unit: unit,
              unitTextStyle: unitTextStyle,
              padNumbers: padNumbers,
            ),
          ),
          actions: actionsButtons,
        ),
      );
    },
  );

  // Return null if Cancel was pressed, otherwise return the selected number
  if (pressedButton == "Cancel") return null;

  return selectedValue;
}
