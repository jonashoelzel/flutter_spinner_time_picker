// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'spinner_number_picker_widget.dart';

// Define a StatefulWidget for a custom time picker widget
class SpinnerTimePicker extends StatefulWidget {
  // Initialize parameters for the time picker
  final TimeOfDay? initTime; // Initial time value
  final ValueNotifier<TimeOfDay>? forceUpdateTimeNotifier;
  final bool is24HourFormat; // Indicates if the time format is 24-hour
  final double spinnerHeight; // Height of the widget
  final double spinnerWidth; // Width of the widget
  final double elementsSpace; // Space between hour and minute pickers
  final double digitHeight; // Height of individual time elements
  final Color spinnerBgColor; // Background color of the widget
  final TextStyle selectedTextStyle; // Text style for selected time elements
  final TextStyle
      nonSelectedTextStyle; // Text style for non-selected time elements
  final void Function(TimeOfDay selected)
      onChangedSelectedTime; // Callback for time selection

  const SpinnerTimePicker({
    this.initTime,
    this.forceUpdateTimeNotifier,
    required this.is24HourFormat,
    required this.spinnerHeight,
    required this.spinnerWidth,
    required this.elementsSpace,
    required this.digitHeight,
    required this.spinnerBgColor,
    required this.selectedTextStyle,
    required this.nonSelectedTextStyle,
    required this.onChangedSelectedTime,
    super.key,
  }) : assert(
            (initTime != null || forceUpdateTimeNotifier != null) &&
                (initTime == null || forceUpdateTimeNotifier == null),
            'Either initTime xor forceUpdateTimeNotifier must be provided');

  @override
  State<SpinnerTimePicker> createState() => _SpinnerTimePickerState();
}

// Define the state for the SpinnerTimePicker widget
class _SpinnerTimePickerState extends State<SpinnerTimePicker> {
  DayPeriod selectedDayPeriod = DayPeriod.am; // Selected AM/PM period

  int selectedHour = 0; // Selected hour value
  ValueNotifier<int> selectedHourNotifier = ValueNotifier<int>(0);

  int selectedMinute = 0; // Selected minute value
  ValueNotifier<int> selectedMinuteNotifier = ValueNotifier<int>(0);

  late ValueNotifier<TimeOfDay> timeChangeNotifier;

  // Options for AM and PM periods
  final _dayPeriodOptions = const [DayPeriod.am, DayPeriod.pm];

  @override
  void initState() {
    // Initialize state variables based on the initial time
    if (widget.forceUpdateTimeNotifier == null) {
      timeChangeNotifier = ValueNotifier<TimeOfDay>(widget.initTime!);
    } else {
      timeChangeNotifier = widget.forceUpdateTimeNotifier!;
    }
    super.initState();
  }

  // Get a list indicating which day period is selected
  List<bool> get _isSelectedDayPeriod {
    return switch (selectedDayPeriod) {
      DayPeriod.am => [true, false], // AM is selected
      DayPeriod.pm => [false, true], // PM is selected
    };
  }

  @override
  Widget build(BuildContext context) {
    // Build the time picker layout
    return ValueListenableBuilder(
      valueListenable: timeChangeNotifier,
      builder: (context, value, _) {
        selectedDayPeriod = value.period;
        selectedHour = !widget.is24HourFormat && selectedDayPeriod == DayPeriod.pm
            ? value.hour - 12
            : value.hour;
        selectedMinute = value.minute;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            _hourPicker(),
            _timeSeparator(context),
            _minutePicker(),
            if (!widget.is24HourFormat) SizedBox(width: 0.7 * widget.elementsSpace),
            if (!widget.is24HourFormat) _dayPeriodSelector(),
          ],
        );
      }
    );
  }

  // Build the day period selector toggle buttons
  ToggleButtons _dayPeriodSelector() {
    return ToggleButtons(
      isSelected: _isSelectedDayPeriod,
      direction: Axis.vertical,
      onPressed: (index) {
        setState(() {
          selectedDayPeriod = _dayPeriodOptions[index];
        });
        setSelectedTime();
      },
      children: _dayPeriodOptions
          .map((option) => Text(option.name.toUpperCase()))
          .toList(),
    );
  }

  // Build the minute picker
  SpinnerNumericPicker _minutePicker() {
    return SpinnerNumericPicker(
      forceUpdateValueNotifier: selectedMinuteNotifier,
      maxValue: 60,
      height: widget.spinnerHeight,
      width: widget.spinnerWidth,
      digitHeight: widget.digitHeight,
      nonSelectedTextStyle: widget.nonSelectedTextStyle,
      selectedTextStyle: widget.selectedTextStyle,
      spinnerBgColor: widget.spinnerBgColor,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMinute = value;
        });
        setSelectedTime();
      },
    );
  }

  // Build the time separator between hour and minute pickers
  SizedBox _timeSeparator(BuildContext context) {
    return SizedBox(
      width: widget.elementsSpace,
      child: Center(
        child: Text(
          ':',
          style: TextStyle(
              fontSize: 23, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  // Build the hour picker
  SpinnerNumericPicker _hourPicker() {
    return SpinnerNumericPicker(
      maxValue: widget.is24HourFormat ? 24 : 12,
      forceUpdateValueNotifier: selectedHourNotifier,
      height: widget.spinnerHeight,
      width: widget.spinnerWidth,
      digitHeight: widget.digitHeight,
      nonSelectedTextStyle: widget.nonSelectedTextStyle,
      selectedTextStyle: widget.selectedTextStyle,
      spinnerBgColor: widget.spinnerBgColor,
      onSelectedItemChanged: (value) async {
        setState(() {
          selectedHour = value;
        });
        setSelectedTime();
      },
    );
  }

  // Update the selected time based on user choices
  void setSelectedTime() {
    final offset =
        !widget.is24HourFormat && selectedDayPeriod == DayPeriod.pm ? 12 : 0;
    widget.onChangedSelectedTime(
        TimeOfDay(hour: selectedHour + offset, minute: selectedMinute));
  }
}
