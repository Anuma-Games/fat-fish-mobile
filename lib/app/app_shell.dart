import 'package:fat_fish_mobile/app/nav_bar.dart';
import 'package:fat_fish_mobile/core/config/app_config.dart';
import 'package:fat_fish_mobile/core/presentation/bars_visibility.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/casino_background.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/status_bar_blur.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/haptics.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
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
  static const _sectionHistoryLimit = 5;
  final _barsVisible = ValueNotifier(true);
  final _sectionHistory = <int>[];
  int? _backTarget;
  int? _swipeFrom;
  bool _swipeBack = false;
  double _swipeDistance = 0;

  void _cancelSectionSwipe() {
    _swipeFrom = null;
    _swipeBack = false;
    _swipeDistance = 0;
  }

  void _startSectionSwipe(DragStartDetails details) {
    _cancelSectionSwipe();
    // Stacked pages keep their platform back gesture instead of switching tabs.
    if (_backTarget == null && !GoRouter.of(context).canPop()) {
      _swipeFrom = widget.navigationShell.currentIndex;
      // Reserve the edge for history; ordinary content swipes keep tab order.
      _swipeBack = details.localPosition.dx <= 24;
    }
  }

  void _endSectionSwipe(DragEndDetails details) {
    final from = _swipeFrom;
    final distance = _swipeDistance;
    final back = _swipeBack;
    _cancelSectionSwipe();
    if (from == null ||
        from != widget.navigationShell.currentIndex ||
        GoRouter.of(context).canPop()) {
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    if (back) {
      if (distance >= 64 || (distance >= 24 && velocity >= 600)) {
        _returnToPreviousSection();
      }
      return;
    }
    final dragged = distance.abs() >= 64;
    final flicked = distance.abs() >= 24 && velocity.abs() >= 600;
    if (!dragged && !flicked) return;
    final direction = dragged ? distance : velocity;
    final next = from + (direction < 0 ? 1 : -1);
    if (next < 0 || next >= AppShell.tabs.length) return;
    Haptics.light(context);
    _openTab(next);
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cancelSectionSwipe();
    final previous = oldWidget.navigationShell.currentIndex;
    final current = widget.navigationShell.currentIndex;
    if (previous != current) {
      // Returning consumes history; it must not create a loop back to itself.
      if (current != _backTarget) {
        _sectionHistory.add(previous);
        if (_sectionHistory.length > _sectionHistoryLimit) {
          _sectionHistory.removeAt(0);
        }
      }
      _backTarget = null;
    }
    // A new tab, or a new screen in the same tab, starts with both bars.
    _barsVisible.value = true;
  }

  void _returnToPreviousSection() {
    if (_backTarget != null || _sectionHistory.isEmpty) return;
    final target = _sectionHistory.removeLast();
    setState(() => _backTarget = target);
    Haptics.light(context);
    _openTab(target);
    // The router rebuilds the shell in the next frame. If that change never
    // arrives, release the lock so the tabs and back keep working.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _backTarget != target) return;
      if (widget.navigationShell.currentIndex == target) return;
      setState(() {
        _backTarget = null;
        _sectionHistory.add(target);
      });
    });
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

  void _openTab(int index) {
    if (_backTarget != null && index != _backTarget) return;
    widget.navigationShell.goBranch(
      index,
      // Tapping the open tab again returns it to its first screen.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.base);

    // Keep the root route's native-back registration in step with the nested
    // stack, including when a root-level page (Ajustes) has just closed.
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (result) {
        final router = GoRouter.of(context);
        if (_backTarget != null) return;
        if (router.canPop()) {
          router.pop(result);
        } else {
          _returnToPreviousSection();
        }
      },
      child: PopScope<Object?>(
        // Register native Android back even when only section history remains.
        // NavigatorPopHandler above is the sole handler for a blocked root pop.
        canPop: _sectionHistory.isEmpty && _backTarget == null,
        child: BarsVisibility(
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
        ),
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
          child: Listener(
            // Clear a recognized drag before Flutter delivers its end on cancel.
            onPointerCancel: (_) => _cancelSectionSwipe(),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.down,
              onHorizontalDragStart: _startSectionSwipe,
              onHorizontalDragUpdate: (details) =>
                  _swipeDistance += details.delta.dx,
              onHorizontalDragEnd: _endSectionSwipe,
              onHorizontalDragCancel: _cancelSectionSwipe,
              child: CasinoBackground(child: widget.navigationShell),
            ),
          ),
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
