import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';

// Define a StatefulWidget for a time element picker widget
class SpinnerNumericPicker extends StatefulWidget {
  // Initialize parameters for the time element picker
  final AlwaysChangeValueNotifier<int>
      _forceUpdateValueNotifier; // Initial value of the picker
  final int maxValue; // Maximum value of the picker
  final int steps; // Steps for the picker
  final double height; // Height of the widget
  final double width; // Width of the widget
  final double digitHeight; // Height of individual time elements
  final TextStyle selectedTextStyle; // Text style for selected time elements
  final TextStyle
      nonSelectedTextStyle; // Text style for non-selected time elements
  final Color spinnerBgColor; // Background color of the widget
  final void Function(int value)
      onSelectedItemChanged; // Callback for value selection
  final bool padNumbers;

  SpinnerNumericPicker({
    AlwaysChangeValueNotifier<int>? forceUpdateValueNotifier,
    required int maxValue,
    required this.height,
    required this.width,
    required this.digitHeight,
    required this.selectedTextStyle,
    required this.nonSelectedTextStyle,
    required this.onSelectedItemChanged,
    required this.spinnerBgColor,
    this.padNumbers = true,
    this.steps = 1,
    super.key,
  })  : maxValue = (maxValue / steps).ceil(),
        _forceUpdateValueNotifier =
            forceUpdateValueNotifier ?? AlwaysChangeValueNotifier<int>(0);

  @override
  State<SpinnerNumericPicker> createState() => _SpinnerNumericPickerState();
}

// Define the state for the TimeElementPicker widget
class _SpinnerNumericPickerState extends State<SpinnerNumericPicker> {
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
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.spinnerBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: scrollController,
        itemExtent: widget.digitHeight,
        // Height of each time element
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final wrappedIndex = (index % widget.maxValue) *
                widget.steps; // Wrap around the values
            return Center(
              child: Text(
                widget.padNumbers
                    ?
                    // Display with leading zero
                    wrappedIndex.toString().padLeft(
                        log10(widget.maxValue * widget.steps).ceil(), '0')
                    : wrappedIndex.toString(),
                style: wrappedIndex == _selectedValue
                    ? widget.selectedTextStyle
                    : widget.nonSelectedTextStyle,
              ),
            );
          },
        ),
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedValue = (index % widget.maxValue) * widget.steps;
          });
          // Notify the parent about the value change
          widget.onSelectedItemChanged(_selectedValue);
        },
      ),
    );
  }

  double log10(num x) => log(x) / ln10;
}
