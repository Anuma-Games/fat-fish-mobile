import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Volume in [levels] cream blocks; tapping or sliding along it picks a level. Greyed
/// while the sound is off, so it reads as the level it will have.
class VolumeBar extends StatelessWidget {
  const VolumeBar({
    super.key,
    required this.value,
    required this.levels,
    required this.active,
    required this.onChanged,
  });

  final int value;
  final int levels;

  /// Whether the sound is on.
  final bool active;
  final ValueChanged<int> onChanged;

  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    final percent = '${value * 100 ~/ levels} %';

    return Semantics(
      container: true,
      slider: true,
      label: 'Volumen',
      value: percent,
      increasedValue: '${(value + 1).clamp(0, levels) * 100 ~/ levels} %',
      decreasedValue: '${(value - 1).clamp(0, levels) * 100 ~/ levels} %',
      onIncrease: () => onChanged((value + 1).clamp(0, levels)),
      onDecrease: () => onChanged((value - 1).clamp(0, levels)),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Left of the first block is 0; each block's right half turns it on.
          void pick(double dx) => onChanged(
            (dx / constraints.maxWidth * levels).round().clamp(0, levels),
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => pick(details.localPosition.dx),
            onHorizontalDragUpdate: (details) => pick(details.localPosition.dx),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  for (var level = 1; level <= levels; level++) ...[
                    if (level > 1) const SizedBox(width: _gap),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: level > value
                              ? FatFishColors.line
                              : active
                              ? FatFishColors.cream100
                              : FatFishColors.fog400,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
