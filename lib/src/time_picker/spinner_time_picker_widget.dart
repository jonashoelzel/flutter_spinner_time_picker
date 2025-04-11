// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';

import '../raw_number_spinner.dart';

class SpinnerTimePickerOptions {
  final RawNumberSpinnerOptions spinnerOptions;
  final double elementsSpace;
  final bool is24HourFormat;
  final bool enableHapticFeedback;

  const SpinnerTimePickerOptions({
    required this.spinnerOptions,
    required this.elementsSpace,
    required this.is24HourFormat,
    this.enableHapticFeedback = true,
  });

  factory SpinnerTimePickerOptions.fromContext(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SpinnerTimePickerOptions(
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context),
      elementsSpace: 0.1 * (0.8 * size.width),
      is24HourFormat: true,
      enableHapticFeedback: true,
    );
  }

  SpinnerTimePickerOptions copyWith({
    RawNumberSpinnerOptions? spinnerOptions,
    double? elementsSpace,
    bool? is24HourFormat,
    bool? enableHapticFeedback,
  }) {
    return SpinnerTimePickerOptions(
      spinnerOptions: spinnerOptions ?? this.spinnerOptions,
      elementsSpace: elementsSpace ?? this.elementsSpace,
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }
}

// Define a StatefulWidget for a custom time picker widget
class SpinnerTimePicker extends StatefulWidget {
  final TimeOfDay? initTime;
  final AlwaysChangeValueNotifier<TimeOfDay>? forceUpdateTimeNotifier;
  final SpinnerTimePickerOptions options;
  final void Function(TimeOfDay selected) onChangedSelectedTime;

  const SpinnerTimePicker({
    this.initTime,
    this.forceUpdateTimeNotifier,
    required this.options,
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
  DayPeriod selectedDayPeriod = DayPeriod.am;
  int selectedHour = 0;
  AlwaysChangeValueNotifier<int> selectedHourNotifier =
      AlwaysChangeValueNotifier<int>(0);
  int selectedMinute = 0;
  AlwaysChangeValueNotifier<int> selectedMinuteNotifier =
      AlwaysChangeValueNotifier<int>(0);
  late AlwaysChangeValueNotifier<TimeOfDay> timeChangeNotifier;
  final _dayPeriodOptions = const [DayPeriod.am, DayPeriod.pm];

  @override
  void initState() {
    if (widget.forceUpdateTimeNotifier == null) {
      timeChangeNotifier =
          AlwaysChangeValueNotifier<TimeOfDay>(widget.initTime!);
    } else {
      timeChangeNotifier = widget.forceUpdateTimeNotifier!;
    }

    timeChangeNotifier.addListener(onChangeRunner);
    _setValues();
    super.initState();
  }

  List<bool> get _isSelectedDayPeriod {
    return switch (selectedDayPeriod) {
      DayPeriod.am => [true, false],
      DayPeriod.pm => [false, true],
    };
  }

  onChangeRunner() => setState(() => _setValues());

  @override
  void dispose() {
    timeChangeNotifier.removeListener(onChangeRunner);
    super.dispose();
  }

  void _setValues() {
    selectedDayPeriod = timeChangeNotifier.value.period;
    selectedHourNotifier.value = selectedHour =
        !widget.options.is24HourFormat && selectedDayPeriod == DayPeriod.pm
            ? timeChangeNotifier.value.hour - 12
            : timeChangeNotifier.value.hour;
    selectedMinuteNotifier.value =
        selectedMinute = timeChangeNotifier.value.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        _hourPicker(),
        _timeSeparator(context),
        _minutePicker(),
        if (!widget.options.is24HourFormat)
          SizedBox(width: 0.7 * widget.options.elementsSpace),
        if (!widget.options.is24HourFormat) _dayPeriodSelector(),
      ],
    );
  }

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

  RawNumberSpinner _minutePicker() {
    return RawNumberSpinner(
      forceUpdateValueNotifier: selectedMinuteNotifier,
      maxValue: 60,
      options: widget.options.spinnerOptions,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMinute = value;
        });
        setSelectedTime();
      },
    );
  }

  SizedBox _timeSeparator(BuildContext context) {
    return SizedBox(
      width: widget.options.elementsSpace,
      child: Center(
        child: Text(
          ':',
          style: TextStyle(
              fontSize: 23, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  RawNumberSpinner _hourPicker() {
    return RawNumberSpinner(
      maxValue: widget.options.is24HourFormat ? 24 : 12,
      forceUpdateValueNotifier: selectedHourNotifier,
      options: widget.options.spinnerOptions,
      onSelectedItemChanged: (value) async {
        setState(() {
          selectedHour = value;
        });
        setSelectedTime();
      },
    );
  }

  void setSelectedTime() {
    final offset =
        !widget.options.is24HourFormat && selectedDayPeriod == DayPeriod.pm
            ? 12
            : 0;
    widget.onChangedSelectedTime(
        TimeOfDay(hour: selectedHour + offset, minute: selectedMinute));
  }
}
