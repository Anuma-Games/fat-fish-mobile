import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/dashed_circle.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/game_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One tab of the bar: its name, and its pixel icon or, for the table, the game icon.
typedef NavTab = ({String label, PixelIcons? icon});

/// Bottom bar of the design: round chips that float over a low dark strip. The active
/// chip grows, with a dashed gold ring and a hard shadow, and shows its name.
///
/// Sliding a finger along the bar moves the highlight to the chip under it; lifting the
/// finger opens that tab.
class FatFishNavBar extends StatefulWidget {
  const FatFishNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
  });

  /// Height above the safe area: the chips and their names over the strip.
  static const height = 100.0;

  /// Height of the dark strip, about half of the chips.
  static const stripHeight = 52.0;

  /// Width of the place of each chip, and the space between them.
  static const _slot = 72.0;
  static const _gap = 20.0;

  final List<NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  State<FatFishNavBar> createState() => _FatFishNavBarState();
}

class _FatFishNavBarState extends State<FatFishNavBar> {
  /// Chip under the finger while it slides; null otherwise.
  int? _dragIndex;

  int _indexAt(double dx, double width) {
    final count = widget.tabs.length;
    final row = count * FatFishNavBar._slot + (count - 1) * FatFishNavBar._gap;
    final pitch = FatFishNavBar._slot + FatFishNavBar._gap;
    final x = dx - (width - row) / 2 + FatFishNavBar._gap / 2;
    return (x / pitch).floor().clamp(0, count - 1);
  }

  void _select(int index) {
    if (index == widget.currentIndex) {
      // Tapping the open tab again still returns it to its first screen.
      widget.onSelect(index);
      return;
    }
    HapticFeedback.lightImpact();
    widget.onSelect(index);
  }

  void _dragTo(double dx, double width) {
    final index = _indexAt(dx, width);
    if (index == _dragIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _dragIndex = index);
  }

  void _endDrag() {
    final index = _dragIndex;
    setState(() => _dragIndex = null);
    if (index != null && index != widget.currentIndex) _select(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final active = _dragIndex ?? widget.currentIndex;

    return SizedBox(
      height: FatFishNavBar.height + bottom,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) =>
              _dragTo(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragUpdate: (details) =>
              _dragTo(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragEnd: (_) => _endDrag(),
          onHorizontalDragCancel: () => setState(() => _dragIndex = null),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: FatFishNavBar.stripHeight + bottom,
                child: ColoredBox(
                  color: FatFishColors.bg900.withValues(alpha: 0.94),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10 + bottom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (index, tab) in widget.tabs.indexed) ...[
                      if (index > 0) const SizedBox(width: FatFishNavBar._gap),
                      _Tab(
                        tab: tab,
                        active: index == active,
                        selected: index == widget.currentIndex,
                        onTap: () => _select(index),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.active,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;

  /// Drawn as the open tab: the open one, or the one under a sliding finger.
  final bool active;

  /// The tab actually open, for screen readers.
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.fast);

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: FatFishNavBar._slot,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tab.icon == null
                  ? _GameChip(active: active, duration: duration)
                  : _PixelChip(
                      icon: tab.icon!,
                      active: active,
                      duration: duration,
                    ),
              const SizedBox(height: 6),
              AnimatedOpacity(
                opacity: active ? 1 : 0,
                duration: duration,
                child: Text(
                  tab.label.toUpperCase(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: FatFishFonts.label,
                    fontSize: 7,
                    letterSpacing: 0.5,
                    color: FatFishColors.gold400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Felt chip with a pixel icon and a dashed ring.
class _PixelChip extends StatelessWidget {
  const _PixelChip({
    required this.icon,
    required this.active,
    required this.duration,
  });

  final PixelIcons icon;
  final bool active;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final size = active ? 60.0 : 52.0;

    return AnimatedContainer(
      duration: duration,
      curve: FatFishMotion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? FatFishColors.felt700 : FatFishColors.felt800,
        boxShadow: active ? FatFishShadows.hard : null,
      ),
      child: CustomPaint(
        painter: DashedCirclePainter(
          color: active ? FatFishColors.gold600 : FatFishColors.line,
          width: 4,
        ),
        child: Center(
          child: PixelIcon(
            icon,
            size: 24,
            color: active ? FatFishColors.gold400 : FatFishColors.fog400,
          ),
        ),
      ),
    );
  }
}

/// The table: the game icon itself, with a dashed gold ring when open.
class _GameChip extends StatelessWidget {
  const _GameChip({required this.active, required this.duration});

  final bool active;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final size = active ? 64.0 : 58.0;

    return AnimatedContainer(
      duration: duration,
      curve: FatFishMotion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: active ? FatFishShadows.hard : null,
      ),
      child: CustomPaint(
        foregroundPainter: active
            ? const DashedCirclePainter(color: FatFishColors.gold600, width: 3)
            : null,
        child: Padding(
          padding: EdgeInsets.all(active ? 3 : 0),
          child: const GameIcon(),
        ),
      ),
    );
  }
}
