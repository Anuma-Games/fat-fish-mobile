import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// [duration], or zero when the phone asks to reduce motion.
Duration motionDuration(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// Fades and slides its child up a few pixels the first time it is built.
/// Give it a key per item: a kept key keeps the item still when the list changes.
class Appear extends StatelessWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = FatFishMotion.base,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final total = motionDuration(context, duration + delay);
    // The delay is the start of the interval: the tween stays at 0 until then.
    final start = total == Duration.zero
        ? 0.0
        : delay.inMicroseconds / total.inMicroseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: FatFishMotion.curve),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
