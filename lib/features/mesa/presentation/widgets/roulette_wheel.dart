import 'dart:math' as math;

import 'package:fat_fish_mobile/core/presentation/widgets/game_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/pocket_colors.dart';
import 'package:flutter/material.dart';

/// The wheel, seen from the chair: a wooden bowl, the ball track with eight gold
/// diamonds and the head with its 37 pockets. [head] and [ball] are angles in turns,
/// clockwise from the top; [ballRadius] runs from [pocketRadius] (in a pocket) to
/// [trackRadius] (on the track).
class RouletteWheel extends StatelessWidget {
  const RouletteWheel({
    super.key,
    required this.head,
    required this.ball,
    required this.ballRadius,
    this.lift = 0,
  });

  static const size = 300.0;
  static const headSize = 240.0;
  static const pocketRadius = 91.0;
  static const trackRadius = 127.0;

  final double head;
  final double ball;
  final double ballRadius;

  /// 0 down in a pocket, up to 1 over a fret: the ball grows and its shadow drops.
  final double lift;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CustomPaint(size: Size.square(size), painter: _BowlPainter()),
          Transform.rotate(
            angle: head * 2 * math.pi,
            child: const SizedBox.square(
              dimension: headSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(headSize),
                    painter: _HeadPainter(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FatFishColors.gold400,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: SizedBox.square(dimension: 88, child: GameIcon()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomPaint(
            size: const Size.square(size),
            painter: _BallPainter(angle: ball, radius: ballRadius, lift: lift),
          ),
        ],
      ),
    );
  }
}

const _woodDark = Color(0xFF2A150A);
const _woodMiddle = Color(0xFF5A3216);
const _woodEdge = Color(0xFF3A1E0C);
const _woodRim = Color(0xFF140904);
const _bowl = Color(0xFF120A06);

class _BowlPainter extends CustomPainter {
  const _BowlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Hard shadow under the wheel.
    canvas.drawCircle(
      center + const Offset(0, 10),
      radius,
      Paint()..color = const Color(0xB3000000),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [_woodDark, _woodDark, _woodMiddle, _woodEdge, _woodRim],
          stops: [0, 0.78, 0.88, 0.96, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(center, radius - 10, Paint()..color = _bowl);
    canvas.drawCircle(
      center,
      radius - 11,
      Paint()
        ..color = FatFishColors.gold600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final diamond = Paint()..color = FatFishColors.gold400;
    for (var i = 0; i < 8; i++) {
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(i * math.pi / 4)
        ..translate(0, -132)
        ..rotate(math.pi / 4)
        ..drawRect(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 8),
          diamond,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_BowlPainter oldDelegate) => false;
}

class _HeadPainter extends CustomPainter {
  const _HeadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi / Roulette.pockets;

    for (var i = 0; i < Roulette.pockets; i++) {
      final number = Roulette.order[i];
      // Canvas angles start at 3 o'clock; the wheel's at 12.
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * sweep,
        sweep,
        true,
        Paint()
          ..color = Roulette.colorOf(number).pocket
          ..isAntiAlias = true,
      );

      final text = TextPainter(
        text: TextSpan(
          text: '$number',
          style: const TextStyle(
            fontFamily: FatFishFonts.display,
            fontSize: 14,
            height: 1,
            color: FatFishColors.cream100,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(i * sweep + sweep / 2)
        ..translate(-text.width / 2, -radius + 4);
      text.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Shadow under the center and the wooden cone with its gold rim.
    canvas.drawCircle(center, 86, Paint()..color = const Color(0x73000000));
    canvas.drawCircle(
      center,
      64,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF6B4120), Color(0xFF3B2010), Color(0xFF1C0E06)],
          stops: [0, 0.7, 1],
        ).createShader(Rect.fromCircle(center: center, radius: 64)),
    );
    canvas.drawCircle(
      center,
      62.5,
      Paint()
        ..color = FatFishColors.gold600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_HeadPainter oldDelegate) => false;
}

class _BallPainter extends CustomPainter {
  const _BallPainter({
    required this.angle,
    required this.radius,
    required this.lift,
  });

  final double angle;
  final double radius;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final a = angle * 2 * math.pi;
    final at =
        size.center(Offset.zero) +
        Offset(math.sin(a) * radius, -math.cos(a) * radius);
    final ballSize = 7 * (1 + 0.2 * lift);
    final shadow = 2 + 3 * lift;
    canvas
      ..drawCircle(
        at + Offset(shadow, shadow),
        ballSize,
        Paint()..color = const Color(0xFF000000),
      )
      ..drawCircle(at, ballSize, Paint()..color = FatFishColors.cream100);
  }

  @override
  bool shouldRepaint(_BallPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.radius != radius ||
      oldDelegate.lift != lift;
}
