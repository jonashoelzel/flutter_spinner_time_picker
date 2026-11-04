// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Width of the dialog content.
  ///
  /// When `null` (the default) the content sizes itself to the picker's
  /// intrinsic width and is capped at the available dialog width, so the
  /// layout always fits regardless of which fields are shown, locale or text
  /// scale. Provide a value only to force a fixed width.
  final double? width;
  final EdgeInsets? contentPadding;
  final String cancelButtonLabel;
  final String okButtonLabel;
  final String infinityButtonLabel;
  final bool showInfinityButton;
  final SpinnerDurationPickerOptions pickerOptions;

  /// Builds a hint below the wheels from the value they show right now. It is
  /// called again on every wheel change, so it can react while the user is
  /// still scrolling. Return `null` to show nothing; the dialog then looks as
  /// if there was no builder.
  ///
  /// The hint wraps to the width of the wheels and never widens the dialog.
  final Widget? Function(BuildContext context, Duration selected)? hintBuilder;

  const SpinnerDurationPickerDialogOptions({
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
    this.hintBuilder,
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
    Widget? Function(BuildContext context, Duration selected)? hintBuilder,
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
      hintBuilder: hintBuilder ?? this.hintBuilder,
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
  final initialDuration = initDuration ?? Duration.zero;
  Duration selectedDuration = initialDuration == INFINITY_DURATION
      ? INFINITY_DURATION
      : Duration(
          milliseconds: (initialDuration.inMilliseconds / 100).round() * 100,
        );

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
          content: _DurationPickerContent(
            initDuration: selectedDuration,
            options: effectiveOptions,
            onChanged: (duration) {
              selectedDuration = duration;
            },
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

/// The wheels and, with a [SpinnerDurationPickerDialogOptions.hintBuilder], the
/// hint below them.
class _DurationPickerContent extends StatefulWidget {
  const _DurationPickerContent({
    required this.initDuration,
    required this.options,
    required this.onChanged,
  });

  final Duration initDuration;
  final SpinnerDurationPickerDialogOptions options;
  final ValueChanged<Duration> onChanged;

  @override
  State<_DurationPickerContent> createState() => _DurationPickerContentState();
}

class _DurationPickerContentState extends State<_DurationPickerContent> {
  late Duration _selected = widget.initDuration;

  @override
  Widget build(BuildContext context) {
    final hintBuilder = widget.options.hintBuilder;
    final wheels = SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: SpinnerDurationPicker(
        initDuration: widget.initDuration,
        options: widget.options.pickerOptions,
        onChangedSelectedDuration: (duration) {
          widget.onChanged(duration);
          if (hintBuilder != null) setState(() => _selected = duration);
        },
      ),
    );
    if (hintBuilder == null) return wheels;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wheels,
        _NoIntrinsicWidth(
          // The dialog is centered, so the wheels move when it grows. They
          // can be under the user's finger, so that must not be a jump.
          child: AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: hintBuilder(context, _selected) ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Keeps [child] out of the dialog's width: an [AlertDialog] sizes itself to
/// the intrinsic width of its content, which for a text is its single-line
/// width. The child takes the width the rest of the content settles on.
class _NoIntrinsicWidth extends SingleChildRenderObjectWidget {
  const _NoIntrinsicWidth({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderNoIntrinsicWidth();
}

class _RenderNoIntrinsicWidth extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}
