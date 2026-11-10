import 'dart:math' as math;

/// Color of a pocket of the wheel.
enum PocketColor { green, red, black }

/// The European wheel of the table: 37 pockets, their order and colors, and where the
/// head must stop so a pocket lands under the ball. Angles are in turns, clockwise from
/// the top.
abstract final class Roulette {
  /// Numbers around the head, clockwise from the zero.
  static const order = [
    0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, //
    5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26,
  ];

  static const _reds = {
    1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36, //
  };

  static int get pockets => order.length;

  /// Width of one pocket.
  static double get step => 1 / pockets;

  static PocketColor colorOf(int number) => number == 0
      ? PocketColor.green
      : _reds.contains(number)
      ? PocketColor.red
      : PocketColor.black;

  /// Angle of the ball in the frame of the head (it rides the head) after it runs
  /// [laps] turns the other way from [current] and lands in the center of the pocket at
  /// [index]. Where that is on the table depends on how far the head has turned, so the
  /// ball falls anywhere around the wheel, as in the PWA.
  static double ballTarget(double current, int index, {int laps = 8}) {
    final center = index * step + step / 2;
    return current - (laps + _mod(current - center, 1));
  }

  /// Across a pocket (0 center, 0.5 fret, 1 next center): the ball lingers in the pocket
  /// and hops the fret.
  static double fretHop(double f) => _smooth(0, 1, _smooth(0, 1, f));

  static double _smooth(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  /// Index of a random pocket.
  static int pick(math.Random random) => random.nextInt(pockets);

  static double _mod(double a, double n) => ((a % n) + n) % n;
}

/// Paces the clicks of the ball against the frets during one spin, like the PWA: as
/// many as frets it passes, at most [maxPerSecond] while fast and fewer as it slows, so
/// the rattle decelerates with the wheel.
class ClickPacer {
  /// Faster than this the clicks would blur into a hiss.
  static const maxPerSecond = 34.0;

  double _pending = 0;

  /// Speed of the ball at [progress] of the spin, from 1 at the start to 0 at the end.
  static double speedAt(double progress) =>
      math.pow(1 - progress, 2).toDouble();

  /// 0 while the ball runs the track, 1 once it falls among the frets.
  static double amongFrets(double progress) => _smooth(0.45, 0.72, progress);

  /// Clicks to play for a frame of [seconds] at [progress], passing [fretsPerSecond].
  int advance({
    required double progress,
    required double seconds,
    required double fretsPerSecond,
  }) {
    final cap = maxPerSecond * (0.35 + 0.65 * speedAt(progress));
    _pending += math.min(fretsPerSecond.abs(), cap) * seconds;
    final clicks = _pending.floor();
    _pending -= clicks;
    return clicks;
  }

  void reset() => _pending = 0;

  static double _smooth(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }
}
