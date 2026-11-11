import 'package:flutter/widgets.dart';

/// Buttons at the end of a top bar; [settings] is false on the settings screen itself.
typedef AppBarActionsBuilder = Widget Function(
  BuildContext context, {
  required bool settings,
});

/// Gives every top bar the same buttons (sound and settings) without core knowing the
/// features behind them: the app puts this above the router. Without it, as in widget
/// tests, the bars have no buttons.
class AppBarActions extends InheritedWidget {
  const AppBarActions({super.key, required this.builder, required super.child});

  final AppBarActionsBuilder builder;

  static AppBarActionsBuilder? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppBarActions>()?.builder;

  @override
  bool updateShouldNotify(AppBarActions oldWidget) =>
      builder != oldWidget.builder;
}
