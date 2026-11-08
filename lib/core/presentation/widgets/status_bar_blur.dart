import 'dart:ui';

import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Frosted strip behind the phone's status bar, like the App Store's: the content that
/// scrolls under it stays readable, but blurred and a little darker, so the clock and
/// the battery read clearly over it. The blur fades out in a few steps below the bar,
/// so it has no hard edge.
class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key});

  /// Blur of each band, from the status bar down, and the height of the fading ones.
  static const _fade = [4.0, 2.0];
  static const _fadeBand = 8.0;
  static const _sigma = 6.0;

  /// Darkening over the status bar; each fading band takes half of the one above.
  static const _tint = 0.35;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return const SizedBox.shrink();

    Widget band(double height, double sigma, double tint) => ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(
          color: FatFishColors.bg900.withValues(alpha: tint),
          child: SizedBox(height: height, width: double.infinity),
        ),
      ),
    );

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            band(top, _sigma, _tint),
            for (final (index, sigma) in _fade.indexed)
              band(_fadeBand, sigma, _tint / (2 << index)),
          ],
        ),
      ),
    );
  }
}
