// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/src/always_change_value_notifier.dart';

import '../raw_number_spinner.dart';

class SpinnerDurationPickerOptions {
  final RawNumberSpinnerOptions spinnerOptions;
  final double elementsSpace;
  final bool hideSeconds;
  final bool hideMinutes;
  final bool hideHours;
  final bool hideMilliseconds;
  final bool enableHapticFeedback;
  final bool showInfinityBetweenSmallestAndLargestValue;

  const SpinnerDurationPickerOptions({
    required this.spinnerOptions,
    required this.elementsSpace,
    this.hideSeconds = false,
    this.hideMinutes = false,
    this.hideHours = false,
    this.hideMilliseconds = true,
    this.enableHapticFeedback = true,
    this.showInfinityBetweenSmallestAndLargestValue = false,
  });

  factory SpinnerDurationPickerOptions.fromContext(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SpinnerDurationPickerOptions(
      spinnerOptions: RawNumberSpinnerOptions.fromContext(context),
      elementsSpace: 0.08 * (0.85 * size.width),
    );
  }

  SpinnerDurationPickerOptions copyWith({
    RawNumberSpinnerOptions? spinnerOptions,
    double? elementsSpace,
    bool? hideSeconds,
    bool? hideMinutes,
    bool? hideHours,
    bool? hideMilliseconds,
    bool? enableHapticFeedback,
    bool? showInfinityBetweenSmallestAndLargestValue,
  }) {
    return SpinnerDurationPickerOptions(
      spinnerOptions: spinnerOptions ?? this.spinnerOptions,
      elementsSpace: elementsSpace ?? this.elementsSpace,
      hideSeconds: hideSeconds ?? this.hideSeconds,
      hideMinutes: hideMinutes ?? this.hideMinutes,
      hideHours: hideHours ?? this.hideHours,
      hideMilliseconds: hideMilliseconds ?? this.hideMilliseconds,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      showInfinityBetweenSmallestAndLargestValue:
          showInfinityBetweenSmallestAndLargestValue ??
              this.showInfinityBetweenSmallestAndLargestValue,
    );
  }
}

// Define a StatefulWidget for a custom duration picker widget
class SpinnerDurationPicker extends StatefulWidget {
  final Duration? initDuration;
  final AlwaysChangeValueNotifier<Duration>? forceUpdateDurationNotifier;
  final SpinnerDurationPickerOptions options;
  final void Function(Duration selected) onChangedSelectedDuration;

  const SpinnerDurationPicker({
    this.initDuration,
    this.forceUpdateDurationNotifier,
    required this.options,
    required this.onChangedSelectedDuration,
    super.key,
  }) : assert(
            (initDuration != null || forceUpdateDurationNotifier != null) &&
                (initDuration == null || forceUpdateDurationNotifier == null),
            'Either initDuration xor durationChangeNotifier must be provided');

  @override
  State<SpinnerDurationPicker> createState() => _SpinnerDurationPickerState();
}

// Define the state for the SpinnerDurationPicker widget
class _SpinnerDurationPickerState extends State<SpinnerDurationPicker> {
  int selectedHour = 0;
  AlwaysChangeValueNotifier<int> selectedHourNotifier =
      AlwaysChangeValueNotifier<int>(0);

  int selectedMinute = 0;
  AlwaysChangeValueNotifier<int> selectedMinuteNotifier =
      AlwaysChangeValueNotifier<int>(0);

  int selectedSecond = 0;
  AlwaysChangeValueNotifier<int> selectedSecondNotifier =
      AlwaysChangeValueNotifier<int>(0);

  int selectedMillisecond = 0;
  AlwaysChangeValueNotifier<int> selectedMillisecondNotifier =
      AlwaysChangeValueNotifier<int>(0);

  late AlwaysChangeValueNotifier<Duration> durationChangeNotifier;

  @override
  void initState() {
    if (widget.forceUpdateDurationNotifier == null) {
      durationChangeNotifier = AlwaysChangeValueNotifier(widget.initDuration!);
    } else {
      durationChangeNotifier = widget.forceUpdateDurationNotifier!;
    }

    durationChangeNotifier.addListener(onChangeRunner);

    _setValues();

    super.initState();
  }

  onChangeRunner() => setState(() => _setValues());

  @override
  void dispose() {
    durationChangeNotifier.removeListener(onChangeRunner);
    super.dispose();
  }

  void _setValues() {
    selectedHourNotifier.value =
        selectedHour = durationChangeNotifier.value.inHours;
    selectedMinuteNotifier.value =
        selectedMinute = durationChangeNotifier.value.inMinutes.remainder(60);
    selectedSecondNotifier.value =
        selectedSecond = durationChangeNotifier.value.inSeconds.remainder(60);

    final milliseconds =
        durationChangeNotifier.value.inMilliseconds.remainder(1000);
    selectedMillisecondNotifier.value =
        selectedMillisecond = milliseconds == -1 ? -1 : milliseconds ~/ 100;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        widget.options.hideHours ? const SizedBox() : _leftPadding(),
        widget.options.hideHours ? const SizedBox() : _hourPicker(),
        widget.options.hideHours
            ? const SizedBox()
            : _durationSeparator(context, 'h'),
        widget.options.hideMinutes ? const SizedBox() : _minutePicker(),
        widget.options.hideMinutes
            ? const SizedBox()
            : _durationSeparator(context, 'm'),
        widget.options.hideSeconds ? const SizedBox() : _secondPicker(),
        widget.options.hideSeconds
            ? const SizedBox()
            : _durationSeparator(
                context, widget.options.hideMilliseconds ? 's' : '.'),
        widget.options.hideMilliseconds
            ? const SizedBox()
            : _millisecondsPicker(),
        widget.options.hideMilliseconds
            ? const SizedBox()
            : _durationSeparator(context, 's'),
      ],
    );
  }

  RawNumberSpinner _millisecondsPicker() {
    return RawNumberSpinner(
      forceUpdateValueNotifier: selectedMillisecondNotifier,
      maxValue: 10,
      options: widget.options.spinnerOptions.copyWith(
        height: widget.options.spinnerOptions.height - 25,
        width: widget.options.spinnerOptions.width - 15,
        digitHeight: widget.options.spinnerOptions.digitHeight - 10,
        selectedTextStyle:
            widget.options.spinnerOptions.selectedTextStyle.copyWith(
          fontSize:
              widget.options.spinnerOptions.selectedTextStyle.fontSize! * 0.85,
        ),
        nonSelectedTextStyle:
            widget.options.spinnerOptions.nonSelectedTextStyle.copyWith(
          fontSize:
              widget.options.spinnerOptions.nonSelectedTextStyle.fontSize! *
                  0.85,
        ),
        padNumbers: false,
      ),
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMillisecond = value;
        });
        setSelectedDuration();
      },
    );
  }

  RawNumberSpinner _secondPicker() {
    return RawNumberSpinner(
      forceUpdateValueNotifier: selectedSecondNotifier,
      maxValue: 60,
      options: widget.options.spinnerOptions,
      onSelectedItemChanged: (value) {
        setState(() {
          selectedSecond = value;
        });
        setSelectedDuration();
      },
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
        setSelectedDuration();
      },
    );
  }

  RawNumberSpinner _hourPicker() {
    return RawNumberSpinner(
      maxValue: 100,
      forceUpdateValueNotifier: selectedHourNotifier,
      options: widget.options.spinnerOptions,
      onSelectedItemChanged: (value) async {
        setState(() {
          selectedHour = value;
        });
        setSelectedDuration();
      },
    );
  }

  SizedBox _durationSeparator(BuildContext context, String separator) {
    double separatorWidth = widget.options.elementsSpace;

    if (separator == '.' && !widget.options.hideMilliseconds) {
      separatorWidth = widget.options.elementsSpace * 0.4;
    }
    return SizedBox(
      width: separatorWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 0.15 * widget.options.elementsSpace),
          Text(
            separator,
            style: widget.options.spinnerOptions.selectedTextStyle.copyWith(
              fontSize:
                  (widget.options.spinnerOptions.selectedTextStyle.fontSize ??
                          28) *
                      0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftPadding() {
    return Container(
      height: 50,
      width: widget.options.elementsSpace,
      color: Colors.transparent,
    );
  }

  void setSelectedDuration() {
    widget.onChangedSelectedDuration(Duration(
      hours: selectedHour,
      minutes: selectedMinute,
      seconds: selectedSecond,
      milliseconds: selectedMillisecond == -1 ? -1 : selectedMillisecond * 100,
    ));
  }
}
