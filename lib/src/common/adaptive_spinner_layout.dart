import 'package:flutter/material.dart';

/// Lays out a horizontal sequence of spinner columns (and their separators)
/// so the row always adapts to the width it is given.
///
/// Every spinner picker in this package — time, duration and number — is built
/// from the same shape: a row of fixed-size [children] (wheel columns,
/// separators, an AM/PM toggle, a unit label, …). The number and width of those
/// children changes with configuration (24h vs. 12h, hidden duration fields,
/// the user's text scale factor, the device locale). A plain [Row] reserves the
/// children's intrinsic width unconditionally, so as soon as the content is
/// wider than the surrounding box it overflows and the trailing column is
/// clipped.
///
/// [AdaptiveSpinnerLayout] removes that failure mode:
///
/// * The row is sized to its intrinsic width ([MainAxisSize.min]), so a parent
///   that does not impose a tight width (for example a dialog that lets its
///   content size itself) ends up exactly as wide as the content needs — no
///   more, no less.
/// * When the available width *is* smaller than the intrinsic width, the whole
///   row is uniformly scaled down with [BoxFit.scaleDown] instead of being
///   clipped. The content shrinks gracefully and stays fully visible.
///
/// Because [BoxFit.scaleDown] only ever shrinks, content that already fits is
/// rendered at its natural size.
class AdaptiveSpinnerLayout extends StatelessWidget {
  /// Creates an adaptive, horizontally-scaling spinner row.
  const AdaptiveSpinnerLayout({
    required this.children,
    this.alignment = Alignment.center,
    super.key,
  });

  /// The spinner columns and separators laid out left-to-right.
  final List<Widget> children;

  /// How the row is positioned within any extra space the parent provides.
  ///
  /// Defaults to [Alignment.center], matching the centered layout the pickers
  /// have always used.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: children,
      ),
    );
  }
}
