import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Dashed ring drawn inside the bounds, like a CSS `border: dashed` on a circle.
class DashedCirclePainter extends CustomPainter {
  const DashedCirclePainter({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - width) / 2;
    final circumference = 2 * math.pi * radius;
    // Dashes about twice as long as the border is wide, like the browsers draw them.
    final count = (circumference / (width * 3.5)).round();
    final sweep = 2 * math.pi / count;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}
