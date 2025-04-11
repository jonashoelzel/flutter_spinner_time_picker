import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';
import 'package:gaimon/gaimon.dart';

class RawNumberSpinnerOptions {
  final double height;
  final double width;
  final double digitHeight;
  final TextStyle selectedTextStyle;
  final TextStyle nonSelectedTextStyle;
  final Color spinnerBgColor;
  final bool padNumbers;
  final bool enableHapticFeedback;
  final bool showInfinityBetweenSmallestAndLargestValue;

  const RawNumberSpinnerOptions({
    required this.height,
    required this.width,
    required this.digitHeight,
    required this.selectedTextStyle,
    required this.nonSelectedTextStyle,
    required this.spinnerBgColor,
    this.padNumbers = true,
    this.enableHapticFeedback = true,
    this.showInfinityBetweenSmallestAndLargestValue = false,
  });

  factory RawNumberSpinnerOptions.fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return RawNumberSpinnerOptions(
      height: 0.7 * (0.25 * size.height),
      width: 0.19 * (0.85 * size.width),
      digitHeight: 0.35 * (0.7 * (0.25 * size.height)),
      spinnerBgColor:
          isDarkMode ? colorScheme.primary : colorScheme.primaryContainer,
      selectedTextStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? colorScheme.primaryContainer : colorScheme.primary,
      ),
      nonSelectedTextStyle: TextStyle(
        fontSize: 30,
        color: isDarkMode
            ? colorScheme.primaryContainer.withAlpha(200)
            : colorScheme.primary.withAlpha(150),
      ),
    );
  }

  RawNumberSpinnerOptions copyWith({
    double? height,
    double? width,
    double? digitHeight,
    TextStyle? selectedTextStyle,
    TextStyle? nonSelectedTextStyle,
    Color? spinnerBgColor,
    bool? padNumbers,
    bool? enableHapticFeedback,
    bool? showInfinityBetweenSmallestAndLargestValue,
  }) {
    return RawNumberSpinnerOptions(
      height: height ?? this.height,
      width: width ?? this.width,
      digitHeight: digitHeight ?? this.digitHeight,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      nonSelectedTextStyle: nonSelectedTextStyle ?? this.nonSelectedTextStyle,
      spinnerBgColor: spinnerBgColor ?? this.spinnerBgColor,
      padNumbers: padNumbers ?? this.padNumbers,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      showInfinityBetweenSmallestAndLargestValue:
          showInfinityBetweenSmallestAndLargestValue ??
              this.showInfinityBetweenSmallestAndLargestValue,
    );
  }
}

// Define a StatefulWidget for a time element picker widget
class RawNumberSpinner extends StatefulWidget {
  // Initialize parameters for the time element picker
  final AlwaysChangeValueNotifier<int> _forceUpdateValueNotifier;
  final int maxValue;
  final int steps;
  final RawNumberSpinnerOptions options;
  final void Function(int value) onSelectedItemChanged;

  RawNumberSpinner({
    AlwaysChangeValueNotifier<int>? forceUpdateValueNotifier,
    required int maxValue,
    required this.options,
    required this.onSelectedItemChanged,
    this.steps = 1,
    super.key,
  })  : maxValue = (maxValue / steps).ceil() +
            (options.showInfinityBetweenSmallestAndLargestValue ? 1 : 0),
        _forceUpdateValueNotifier =
            forceUpdateValueNotifier ?? AlwaysChangeValueNotifier<int>(0);

  @override
  State<RawNumberSpinner> createState() => _RawNumberSpinnerState();
}

// Define the state for the TimeElementPicker widget
class _RawNumberSpinnerState extends State<RawNumberSpinner> {
  late FixedExtentScrollController scrollController;

  late int _selectedValue;
  late AlwaysChangeValueNotifier<int> forceUpdateValueNotifier;

  int _selectedScrollControllerValue() => _selectedValue ~/ widget.steps;

  @override
  void initState() {
    // Initialize state variables and scroll controller
    forceUpdateValueNotifier = widget._forceUpdateValueNotifier;
    _selectedValue = forceUpdateValueNotifier.value;
    scrollController = FixedExtentScrollController(
        initialItem: _selectedScrollControllerValue());

    forceUpdateValueNotifier.addListener(() {
      _selectedValue = forceUpdateValueNotifier.value;
      scrollController.animateToItem(_selectedScrollControllerValue(),
          duration: const Duration(milliseconds: 800), curve: Curves.easeIn);
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.options.height,
      width: widget.options.width,
      decoration: BoxDecoration(
        color: widget.options.spinnerBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: scrollController,
        itemExtent: widget.options.digitHeight,
        // Height of each time element
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final wrappedIndex = (index % widget.maxValue) *
                widget.steps; // Wrap around the values

            final String numberText;
            if (widget.options.showInfinityBetweenSmallestAndLargestValue &&
                wrappedIndex == (widget.maxValue - 1) * widget.steps) {
              numberText = '∞';
            } else if (widget.options.padNumbers) {
              // Display with leading zero
              numberText = _getPaddedNumber(wrappedIndex);
            } else {
              numberText = wrappedIndex.toString();
            }

            return Center(
              child: Text(
                numberText,
                style: wrappedIndex == _selectedValue
                    ? widget.options.selectedTextStyle
                    : widget.options.nonSelectedTextStyle,
              ),
            );
          },
        ),
        onSelectedItemChanged: (index) {
          setState(
            () {
              _selectedValue = (index % widget.maxValue) * widget.steps;

              if (widget.options.showInfinityBetweenSmallestAndLargestValue &&
                  _selectedValue == (widget.maxValue - 1) * widget.steps) {
                // when infinity is selected the value is -1
                _selectedValue = -1;
              }
            },
          );
          // Notify the parent about the value change
          widget.onSelectedItemChanged(_selectedValue);

          if (widget.options.enableHapticFeedback) {
            if (Platform.isIOS || Platform.isAndroid) {
              Gaimon.canSupportsHaptic.then((value) {
                if (value) {
                  Gaimon.light();
                }
              });
            }
          }
        },
      ),
    );
  }

  String _getPaddedNumber(int number) => number.toString().padLeft(
      log10((widget.maxValue -
                  (widget.options.showInfinityBetweenSmallestAndLargestValue
                      ? 1
                      : 0)) *
              widget.steps)
          .ceil(),
      '0');

  double log10(num x) => log(x) / ln10;
}
