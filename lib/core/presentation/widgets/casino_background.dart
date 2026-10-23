import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Dark casino background with the diamond pattern of the PWA (patron-casino.svg).
/// Pages drawn on top need a transparent Scaffold to let it show.
class CasinoBackground extends StatelessWidget {
  const CasinoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FatFishColors.bg900,
      child: CustomPaint(
        painter: const _DiamondPatternPainter(),
        isComplex: true,
        child: child,
      ),
    );
  }
}

/// Repeats the 48 × 48 SVG tile at 15 % opacity.
class _DiamondPatternPainter extends CustomPainter {
  const _DiamondPatternPainter();

  static const _tile = 48.0;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = FatFishColors.pattern
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..color = FatFishColors.pattern;

    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = const Color.fromRGBO(0, 0, 0, 0.15),
    );
    for (var y = 0.0; y < size.height; y += _tile) {
      for (var x = 0.0; x < size.width; x += _tile) {
        canvas.save();
        canvas.translate(x, y);
        _paintTile(canvas, stroke, fill);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _paintTile(Canvas canvas, Paint stroke, Paint fill) {
    // Diamond and the corner lines that join it with the next tiles.
    canvas.drawPath(
      Path()
        ..moveTo(0, 24)
        ..lineTo(24, 0)
        ..lineTo(48, 24)
        ..lineTo(24, 48)
        ..close(),
      stroke,
    );
    canvas.drawLine(const Offset(-12, 12), const Offset(12, -12), stroke);
    canvas.drawLine(const Offset(36, -12), const Offset(60, 12), stroke);
    canvas.drawLine(const Offset(-12, 36), const Offset(12, 60), stroke);
    canvas.drawLine(const Offset(36, 60), const Offset(60, 36), stroke);

    // Center: a 6 × 6 square turned 45°.
    canvas.drawPath(
      Path()
        ..moveTo(24, 19.76)
        ..lineTo(28.24, 24)
        ..lineTo(24, 28.24)
        ..lineTo(19.76, 24)
        ..close(),
      fill,
    );
    for (final corner in const [
      Offset(22, 9),
      Offset(22, 35),
      Offset(9, 22),
      Offset(35, 22),
    ]) {
      canvas.drawRect(corner & const Size(4, 4), fill);
    }
  }

  @override
  bool shouldRepaint(_DiamondPatternPainter oldDelegate) => false;
}
