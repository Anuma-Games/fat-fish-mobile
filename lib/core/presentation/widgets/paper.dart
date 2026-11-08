import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Text styles for paper: what the casino knows about you is typed in dark ink,
/// like the dossier sheets of the game and the PWA.
abstract final class PaperText {
  /// Small labels in uppercase, like a printed form: "TOTAL PERDIDO".
  static const label = TextStyle(
    fontFamily: FatFishFonts.paper,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 1.5,
    height: 1.45,
    color: FatFishColors.ink500,
  );

  /// Typed values; pass the size of each place.
  static TextStyle typed(
    double fontSize, {
    Color color = FatFishColors.ink900,
  }) => TextStyle(
    fontFamily: FatFishFonts.paper,
    fontWeight: FontWeight.w700,
    fontSize: fontSize,
    height: 1.2,
    color: color,
  );

  /// Notes under a value: "Seguidas".
  static const note = TextStyle(
    fontFamily: FatFishFonts.paper,
    fontSize: 12,
    height: 1.45,
    color: FatFishColors.ink500,
  );
}

/// Cream sheet with faint ruled lines every 4 px. The child draws over the lines.
class RuledPaper extends StatelessWidget {
  const RuledPaper({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.shadow = const [],
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadow),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomPaint(
          painter: const _RuledLinesPainter(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _RuledLinesPainter extends CustomPainter {
  const _RuledLinesPainter();

  static const _spacing = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = FatFishColors.paper100,
    );
    final line = Paint()..color = FatFishColors.ink900.withValues(alpha: 0.06);
    for (var y = 0.0; y < size.height; y += _spacing) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }
  }

  @override
  bool shouldRepaint(_RuledLinesPainter oldDelegate) => false;
}
