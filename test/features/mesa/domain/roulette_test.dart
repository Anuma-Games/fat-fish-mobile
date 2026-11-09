import 'dart:math' as math;

import 'package:fat_fish_mobile/features/mesa/domain/croupier.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the wheel has each number from 0 to 36 once', () {
    expect(Roulette.order.toSet(), {for (var n = 0; n <= 36; n++) n});
    expect(Roulette.order, hasLength(37));
  });

  test('18 red, 18 black and the green zero', () {
    final colors = Roulette.order.map(Roulette.colorOf).toList();

    expect(colors.where((c) => c == PocketColor.red), hasLength(18));
    expect(colors.where((c) => c == PocketColor.black), hasLength(18));
    expect(Roulette.colorOf(0), PocketColor.green);
    expect(Roulette.colorOf(32), PocketColor.red);
    expect(Roulette.colorOf(15), PocketColor.black);
  });

  test('the ball runs the other way and lands in the center of the pocket', () {
    for (final current in [0.0, 0.3, -0.97, -4.5]) {
      for (var index = 0; index < Roulette.pockets; index++) {
        final target = Roulette.ballTarget(current, index);
        final center = index * Roulette.step + Roulette.step / 2;
        final offCenter = target - center;

        expect((offCenter - offCenter.roundToDouble()).abs(), lessThan(1e-9));
        expect(current - target, inInclusiveRange(8, 9));
      }
    }
  });

  test('the ball lingers in the pocket and hops the fret', () {
    expect(Roulette.fretHop(0), 0);
    expect(Roulette.fretHop(0.5), closeTo(0.5, 1e-9));
    expect(Roulette.fretHop(1), 1);
    expect(Roulette.fretHop(0.1), lessThan(0.1));
  });

  test('the clicks slow down with the ball', () {
    int clicksAt(double progress) {
      final pacer = ClickPacer();
      return pacer.advance(progress: progress, seconds: 1, fretsPerSecond: 200);
    }

    expect(clicksAt(0), ClickPacer.maxPerSecond.floor());
    expect(clicksAt(0.5), lessThan(clicksAt(0)));
    expect(clicksAt(1), lessThan(clicksAt(0.5)));
    // Never more clicks than frets passed.
    expect(ClickPacer().advance(progress: 0, seconds: 1, fretsPerSecond: 5), 5);
  });

  test('a fraction of a click is carried to the next frame', () {
    final pacer = ClickPacer();
    final clicks = [
      for (var i = 0; i < 4; i++)
        pacer.advance(progress: 0, seconds: 0.1, fretsPerSecond: 5),
    ];

    expect(clicks.reduce((a, b) => a + b), 2);
  });

  test('the croupier never says the same line twice in a row', () {
    final random = math.Random(3);
    var line = Croupier.greeting;
    for (var i = 0; i < 200; i++) {
      final next = Croupier.next(random, line);
      expect(next, isNot(line));
      expect(next, inInclusiveRange(0, Croupier.lines.length - 1));
      line = next;
    }
  });
}
