import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';
import 'package:gaimon/gaimon.dart';

class RawNumberSpinnerOptions {
  final double height;

  /// Minimum width of the spinner's coloured background box.
  ///
  /// Acts as a floor: the box is never narrower than [width], but grows to fit
  /// the widest digit plus [digitHorizontalPadding] on each side so the numbers
  /// always have breathing room — even with a large font or text-scale factor.
  final double width;
  final double digitHeight;
  final TextStyle selectedTextStyle;
  final TextStyle nonSelectedTextStyle;
  final Color spinnerBgColor;
  final bool padNumbers;
  final bool enableHapticFeedback;
  final bool showInfinityBetweenSmallestAndLargestValue;

  /// Horizontal gap kept between the widest digit and each side of the coloured
  /// background box.
  ///
  /// When `null` (the default) a font-proportional padding is used, so larger
  /// fonts automatically get more breathing room. Pass an explicit value
  /// (including `0`) to override.
  final double? digitHorizontalPadding;

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
    this.digitHorizontalPadding,
  });

  /// The effective per-side horizontal padding, resolving the font-proportional
  /// default when [digitHorizontalPadding] is `null`.
  double get effectiveDigitHorizontalPadding =>
      digitHorizontalPadding ?? 0.35 * (selectedTextStyle.fontSize ?? 28);

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
    double? digitHorizontalPadding,
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
      digitHorizontalPadding:
          digitHorizontalPadding ?? this.digitHorizontalPadding,
    );
  }
}

/// Computes the width of a spinner's coloured background box.
///
/// Measures the widest rendered digit string (derived from [largestValue],
/// honouring the current [textScaler]) and adds
/// [RawNumberSpinnerOptions.effectiveDigitHorizontalPadding] on each side. The
/// configured [RawNumberSpinnerOptions.width] is used only as a floor, so the
/// numbers always keep their breathing room regardless of font or text scale.
double resolveSpinnerBoxWidth({
  required RawNumberSpinnerOptions options,
  required int largestValue,
  required TextScaler textScaler,
}) {
  final digitCount = max(1, largestValue.abs().toString().length);
  final painter = TextPainter(
    text: TextSpan(text: '8' * digitCount, style: options.selectedTextStyle),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  final contentWidth =
      painter.width + 2 * options.effectiveDigitHorizontalPadding;
  return max(options.width, contentWidth);
}

int _numberSpinnerItemCount(
  int minValue,
  int maxValue,
  int steps,
  bool includeInfinity,
) {
  final firstSteppedValue = (minValue ~/ steps + 1) * steps;
  final steppedCount = firstSteppedValue < maxValue
      ? (maxValue - 1 - firstSteppedValue) ~/ steps + 1
      : 0;
  return 1 + steppedCount + (includeInfinity ? 1 : 0);
}

// Define a StatefulWidget for a time element picker widget
class RawNumberSpinner extends StatefulWidget {
  // Initialize parameters for the time element picker
  final AlwaysChangeValueNotifier<int> _forceUpdateValueNotifier;
  final int maxValue;
  final int minValue;
  final int steps;
  final RawNumberSpinnerOptions options;
  final void Function(int value) onSelectedItemChanged;

  RawNumberSpinner({
    AlwaysChangeValueNotifier<int>? forceUpdateValueNotifier,
    required int maxValue,
    this.minValue = 0,
    required this.options,
    required this.onSelectedItemChanged,
    this.steps = 1,
    super.key,
  })  : assert(steps > 0),
        assert(minValue >= 0 && minValue < maxValue),
        maxValue = _numberSpinnerItemCount(
          minValue,
          maxValue,
          steps,
          options.showInfinityBetweenSmallestAndLargestValue,
        ),
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

  int _valueAt(int index) => index == 0
      ? widget.minValue
      : ((widget.minValue ~/ widget.steps) + index) * widget.steps;

  int _selectedScrollControllerValue() {
    if (_selectedValue == -1) return widget.maxValue - 1;
    if (_selectedValue == widget.minValue) return 0;
    return _selectedValue ~/ widget.steps - widget.minValue ~/ widget.steps;
  }

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
    final boxWidth = resolveSpinnerBoxWidth(
      options: widget.options,
      largestValue: _valueAt(widget.maxValue - 1),
      textScaler: MediaQuery.textScalerOf(context),
    );

    return Container(
      height: widget.options.height,
      width: boxWidth,
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
            final wrappedIndex = _valueAt(index % widget.maxValue);

            final infinitySlotValue = _valueAt(widget.maxValue - 1);
            final isInfinityItem =
                widget.options.showInfinityBetweenSmallestAndLargestValue &&
                    wrappedIndex == infinitySlotValue;

            final String numberText;
            if (isInfinityItem) {
              numberText = '∞';
            } else if (widget.options.padNumbers) {
              // Display with leading zero
              numberText = _getPaddedNumber(wrappedIndex);
            } else {
              numberText = wrappedIndex.toString();
            }

            // ∞ is represented two ways: the -1 sentinel (set once the user
            // scrolls onto it) and its positive slot value (used to position
            // the wheel when the dialog opens already on ∞). Treat either as
            // "infinity selected" so the item highlights in both cases.
            final isSelected = isInfinityItem
                ? _selectedValue == -1 || _selectedValue == infinitySlotValue
                : wrappedIndex == _selectedValue;

            return Center(
              child: Text(
                numberText,
                style: isSelected
                    ? widget.options.selectedTextStyle
                    : widget.options.nonSelectedTextStyle,
              ),
            );
          },
        ),
        onSelectedItemChanged: (index) {
          setState(
            () {
              _selectedValue = _valueAt(index % widget.maxValue);

              if (widget.options.showInfinityBetweenSmallestAndLargestValue &&
                  _selectedValue == _valueAt(widget.maxValue - 1)) {
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
        _valueAt(widget.maxValue -
                (widget.options.showInfinityBetweenSmallestAndLargestValue
                    ? 2
                    : 1))
            .toString()
            .length,
        '0',
      );
}
