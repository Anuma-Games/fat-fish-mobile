import 'package:flutter/widgets.dart';

/// Whether the top and bottom bars are on screen. The tabs hide them while the
/// content scrolls down and show them again when it scrolls up.
class BarsVisibility extends InheritedNotifier<ValueNotifier<bool>> {
  const BarsVisibility({
    super.key,
    required ValueNotifier<bool> visible,
    required super.child,
  }) : super(notifier: visible);

  /// True outside the tabs, where nothing hides the bars.
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<BarsVisibility>()
          ?.notifier
          ?.value ??
      true;
}
