import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Square switch of the kit: felt with a gold knob when on, dark with a grey knob when
/// off. 52 × 30, inside a 44 px touch target.
class PixelSwitch extends StatelessWidget {
  const PixelSwitch({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;

  /// What it turns on and off, for screen readers.
  final String label;
  final ValueChanged<bool> onChanged;

  static const _width = 52.0;
  static const _height = 30.0;
  static const _knob = 20.0;
  static const _inset = 3.0;
  static const _border = 2.0;

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.fast);

    return Semantics(
      container: true,
      toggled: value,
      label: label,
      excludeSemantics: true,
      onTap: () => onChanged(!value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: SizedBox(
          width: _width,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: FatFishMotion.curve,
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                color: value ? FatFishColors.felt700 : FatFishColors.bg900,
                border: Border.all(
                  color: value ? FatFishColors.gold400 : FatFishColors.line,
                  width: _border,
                ),
                borderRadius: const BorderRadius.all(FatFishRadius.field),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: FatFishMotion.curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(_inset - _border / 2),
                  child: AnimatedContainer(
                    duration: duration,
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      color: value
                          ? FatFishColors.gold400
                          : FatFishColors.fog400,
                      borderRadius: const BorderRadius.all(FatFishRadius.field),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
