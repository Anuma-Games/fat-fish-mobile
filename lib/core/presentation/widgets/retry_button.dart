import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// "Reintentar" that turns into a small spinner while [onRetry] runs. The word fades
/// out and the spinner fades and grows in its place, in the same space, so nothing
/// around it moves. A second tap while it runs does nothing.
class RetryButton extends StatefulWidget {
  const RetryButton({super.key, required this.onRetry, this.outlined = false});

  final Future<void> Function() onRetry;

  /// Secondary button with a border, for a notice in the middle of the page; plain
  /// gold text otherwise, for a notice that sits over the data.
  final bool outlined;

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _loading = false;

  Future<void> _retry() async {
    setState(() => _loading = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, FatFishMotion.fast);
    final color = widget.outlined
        ? FatFishColors.cream100
        : FatFishColors.gold400;

    // Both stay laid out, so the button keeps the width of the word.
    final label = Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: _loading ? 0 : 1,
          duration: duration,
          curve: FatFishMotion.curve,
          child: const Text('Reintentar'),
        ),
        // The spinner leaves the tree once it fades out, so it does not keep
        // animating out of sight.
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: FatFishMotion.curve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.6, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: _loading
              ? SizedBox.square(
                  key: const ValueKey('loading'),
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('idle')),
        ),
      ],
    );

    final onPressed = _loading ? () {} : _retry;
    final semantics = Semantics(
      label: _loading ? 'Reintentando' : null,
      child: label,
    );

    if (widget.outlined) {
      return OutlinedButton(onPressed: onPressed, child: semantics);
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(
          fontFamily: FatFishFonts.body,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: semantics,
    );
  }
}
