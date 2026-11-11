import 'dart:ui';

import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Dashed border along rounded corners, like a ticket that warns. A [ShapeBorder], so it
/// works as the `shape` of a SnackBar or a [ShapeDecoration].
class DashedBorder extends ShapeBorder {
  const DashedBorder({
    this.color = FatFishColors.gold600,
    this.width = 2,
    this.radius = FatFishRadius.card,
    this.dash = 6,
    this.gap = 4,
  });

  final Color color;
  final double width;
  final Radius radius;
  final double dash;
  final double gap;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  RRect _rrect(Rect rect) => RRect.fromRectAndRadius(rect, radius);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect).deflate(width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final path = Path()..addRRect(_rrect(rect.deflate(width / 2)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) => DashedBorder(
    color: color,
    width: width * t,
    radius: radius * t,
    dash: dash * t,
    gap: gap * t,
  );

  @override
  bool operator ==(Object other) =>
      other is DashedBorder &&
      other.color == color &&
      other.width == width &&
      other.radius == radius &&
      other.dash == dash &&
      other.gap == gap;

  @override
  int get hashCode => Object.hash(color, width, radius, dash, gap);
}
