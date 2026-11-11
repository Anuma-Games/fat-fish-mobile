import 'package:fat_fish_mobile/app/nav_bar.dart';
import 'package:fat_fish_mobile/core/config/app_config.dart';
import 'package:fat_fish_mobile/core/presentation/bars_visibility.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/casino_background.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/status_bar_blur.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

/// Casino background and the floating bottom bar around the three tabs. The content
/// scrolls under both bars, which hide while it scrolls down and come back when it
/// scrolls up or the tab changes.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Same order as the branches of the router.
  static const tabs = <NavTab>[
    (label: 'Expediente', icon: PixelIcons.dossier),
    (label: 'Mesa', icon: null),
    (label: 'Ranking', icon: PixelIcons.ranking),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _barsVisible = ValueNotifier(true);

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new tab, or a new screen in the same tab, starts with both bars.
    _barsVisible.value = true;
  }

  @override
  void dispose() {
    _barsVisible.dispose();
    super.dispose();
  }

  /// A list at its top always shows the bars: the page leaves room for the top bar
  /// there, and without the bar that room would sit empty. This covers a list that is
  /// built again at the top, like a new page of the ranking.
  void _showAtTop(ScrollMetrics metrics) {
    if (metrics.axis == Axis.vertical &&
        metrics.pixels <= metrics.minScrollExtent) {
      _barsVisible.value = true;
    }
  }

  /// A new list reports its first metrics this way, without scrolling.
  bool _onMetrics(ScrollMetricsNotification notification) {
    _showAtTop(notification.metrics);
    return false;
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (notification is ScrollUpdateNotification) _showAtTop(metrics);
    if (notification is! UserScrollNotification) return false;
    // Only the page itself, top to bottom, and only when it has room to scroll:
    // a short page never hides its bars.
    if (metrics.axis != Axis.vertical || metrics.maxScrollExtent <= 0) {
      return false;
    }
    switch (notification.direction) {
      // The direction changes before the offset moves, so a scroll that starts at
      // the top still reads 0 here.
      case ScrollDirection.reverse:
        _barsVisible.value = false;
      case ScrollDirection.forward:
        _barsVisible.value = true;
      case _:
        break;
    }
    return false;
  }

  void _openTab(int index) => widget.navigationShell.goBranch(
    index,
    // Tapping the open tab again returns it to its first screen.
    initialLocation: index == widget.navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.base);

    return BarsVisibility(
      visible: _barsVisible,
      child: Stack(
        children: [
          _scaffold(duration),
          // Once the top bar hides, the content passes under the clock: the blur
          // takes the place of the bar, and fades out when the bar comes back.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ValueListenableBuilder(
              valueListenable: _barsVisible,
              builder: (context, visible, child) => AnimatedOpacity(
                opacity: visible ? 0 : 1,
                duration: duration,
                curve: FatFishMotion.curve,
                child: child,
              ),
              child: const StatusBarBlur(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scaffold(Duration duration) {
    return Scaffold(
      // The content runs under the floating bar; MediaQuery tells the pages how
      // much of the bottom it covers.
      extendBody: true,
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: _onMetrics,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CasinoBackground(child: widget.navigationShell),
        ),
      ),
      floatingActionButton: AppConfig.sentryTestButton
          ? FloatingActionButton.small(
              tooltip: 'Probar Sentry',
              onPressed: () =>
                  throw StateError('Error de prueba para verificar Sentry'),
              child: const Icon(Icons.bug_report),
            )
          : null,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _barsVisible,
        builder: (context, visible, child) => AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1),
          duration: duration,
          curve: FatFishMotion.curve,
          child: child,
        ),
        child: FatFishNavBar(
          tabs: AppShell.tabs,
          currentIndex: widget.navigationShell.currentIndex,
          onSelect: _openTab,
        ),
      ),
    );
  }
}
