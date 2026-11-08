import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Opacity of a light that flickers: the first value of [steps] whose start is at or
/// before [t] (0 to 1 along the cycle). Like CSS keyframes with `steps(1)`.
double stepped(double t, List<(double, double)> steps) {
  var value = 1.0;
  for (final (start, opacity) in steps) {
    if (t >= start) value = opacity;
  }
  return value;
}

/// The lamp over the table: a cord, a metal shade, a bulb and a cone of warm light with
/// dust floating in it. [seconds] runs the animations; the parent stops it to keep the
/// lamp still when the phone asks to reduce motion.
class TableLamp extends StatelessWidget {
  const TableLamp({super.key, required this.seconds});

  /// Time since the screen opened.
  final double seconds;

  /// The lamp turns on with a few flickers during its first [_switchOn] seconds.
  static const _switchOn = 1.6;

  @override
  Widget build(BuildContext context) {
    final on = seconds >= _switchOn
        ? 1.0
        : stepped(seconds / _switchOn, const [
            (0, 0),
            (0.12, 0.9),
            (0.18, 0.1),
            (0.30, 1),
            (0.36, 0.3),
            (0.50, 1),
          ]);
    // Mains flicker of the bulb and the beam, every 11 s.
    final flicker = stepped((seconds % 11) / 11, const [
      (0, 1),
      (0.32, 0.55),
      (0.33, 1),
      (0.72, 0.7),
      (0.73, 0.4),
      (0.74, 1),
    ]);
    // Slow swing of ±0.8° every 9 s, eased in and out.
    final swing =
        -math.cos(2 * math.pi * (seconds % 9) / 9) * 0.8 * math.pi / 180;

    return Opacity(
      opacity: on,
      child: Transform.rotate(
        angle: swing,
        alignment: Alignment.topCenter,
        child: CustomPaint(
          painter: _LampPainter(seconds: seconds, flicker: flicker),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _LampPainter extends CustomPainter {
  const _LampPainter({required this.seconds, required this.flicker});

  final double seconds;
  final double flicker;

  /// Where the beam starts, under the bulb.
  static const _beamTop = 74.0;

  /// Dust motes: left and top as fractions of the beam, size, delay and cycle (s).
  static const _motes = [
    (0.46, 0.08, 2.0, 0.0, 9.0),
    (0.52, 0.18, 3.0, 2.5, 11.0),
    (0.40, 0.30, 2.0, 5.0, 10.0),
    (0.60, 0.36, 2.0, 1.2, 12.0),
    (0.35, 0.52, 3.0, 3.6, 9.0),
    (0.56, 0.58, 2.0, 6.4, 11.0),
    (0.64, 0.70, 2.0, 0.8, 10.0),
    (0.30, 0.76, 3.0, 4.4, 12.0),
    (0.48, 0.84, 2.0, 7.2, 9.0),
    (0.70, 0.88, 2.0, 2.0, 11.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final beam = Rect.fromLTRB(0, _beamTop, size.width, size.height);

    // Cone of light, wider at the bottom, fading towards the table.
    final cone = Path()
      ..moveTo(beam.left + beam.width * 0.42, beam.top)
      ..lineTo(beam.left + beam.width * 0.58, beam.top)
      ..lineTo(beam.left + beam.width * 0.95, beam.bottom)
      ..lineTo(beam.left + beam.width * 0.05, beam.bottom)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..shader = ui.Gradient.linear(
          beam.topCenter,
          beam.bottomCenter,
          [
            FatFishLamp.light.withValues(alpha: 0.30 * flicker),
            FatFishLamp.light.withValues(alpha: 0.13 * flicker),
            FatFishLamp.light.withValues(alpha: 0),
          ],
          const [0, 0.5, 0.96],
        ),
    );

    // Dust drifting up and to the right inside the cone.
    canvas.save();
    canvas.clipPath(cone);
    for (final (left, top, dot, delay, cycle) in _motes) {
      final t = seconds < delay ? -1.0 : ((seconds - delay) % cycle) / cycle;
      if (t < 0) continue;
      final opacity = t < 0.2
          ? t / 0.2 * 0.8
          : t > 0.8
          ? (1 - t) / 0.2 * 0.8
          : 0.8;
      canvas.drawCircle(
        Offset(
          beam.left + beam.width * left + 14 * t,
          beam.top + beam.height * top - 60 * t,
        ),
        dot / 2,
        Paint()..color = FatFishLamp.bulb.withValues(alpha: opacity),
      );
    }
    canvas.restore();

    // Cord, shade and bulb.
    canvas.drawRect(
      Rect.fromLTWH(cx - 1, 0, 2, 30),
      Paint()..color = FatFishLamp.cord,
    );
    const shade = Rect.fromLTWH(-50, 30, 100, 40);
    canvas.save();
    canvas.translate(cx, 0);
    canvas.drawPath(
      Path()
        ..moveTo(shade.left + shade.width * 0.32, shade.top)
        ..lineTo(shade.left + shade.width * 0.68, shade.top)
        ..lineTo(shade.right, shade.bottom)
        ..lineTo(shade.left, shade.bottom)
        ..close(),
      Paint()
        ..shader = ui.Gradient.linear(
          shade.topCenter,
          shade.bottomCenter,
          const [
            FatFishLamp.shadeTop,
            FatFishLamp.shadeMiddle,
            FatFishLamp.shadeBottom,
          ],
          const [0, 0.7, 1],
        ),
    );
    final bulb = Rect.fromCenter(
      center: Offset(0, shade.bottom - 6 + 5.5),
      width: 58,
      height: 11,
    );
    canvas.drawOval(
      bulb.inflate(18),
      Paint()
        ..color = FatFishLamp.light.withValues(alpha: 0.45 * flicker)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawOval(
      bulb,
      Paint()
        ..shader = ui.Gradient.radial(
          bulb.center,
          bulb.width / 2,
          [
            FatFishLamp.bulb.withValues(alpha: flicker),
            FatFishLamp.light.withValues(alpha: flicker),
            FatFishLamp.light.withValues(alpha: 0),
          ],
          const [0, 0.6, 0.75],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LampPainter oldDelegate) =>
      oldDelegate.seconds != seconds || oldDelegate.flicker != flicker;
}
