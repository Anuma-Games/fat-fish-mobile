import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Keeps every tab alive, like `StatefulShellRoute.indexedStack`, but fades the
/// new tab in (with a slight zoom) instead of swapping it at once.
class FadeBranchContainer extends StatelessWidget {
  const FadeBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.base);

    return Stack(
      children: [
        for (final (index, child) in children.indexed)
          _Branch(
            active: index == currentIndex,
            duration: duration,
            child: child,
          ),
      ],
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({
    required this.active,
    required this.duration,
    required this.child,
  });

  final bool active;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Hidden tabs ignore taps, leave the accessibility tree and pause their
    // animations, as they would inside an IndexedStack.
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: duration,
          curve: FatFishMotion.curve,
          child: AnimatedScale(
            scale: active ? 1 : 0.98,
            duration: duration,
            curve: FatFishMotion.curve,
            // Inside the fade, never around it: muting the fade's own ticker
            // would freeze the leaving tab at full opacity over the new one.
            child: TickerMode(
              enabled: active,
              // A hidden tab drops its focus, so its keyboard closes too.
              child: FocusScope(descendantsAreFocusable: active, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
