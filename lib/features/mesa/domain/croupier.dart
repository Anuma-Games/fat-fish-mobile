import 'dart:math' as math;

/// What the croupier says: a greeting when the player sits down and a different line
/// after each spin.
abstract final class Croupier {
  static const lines = [
    'Toma asiento.',
    'La casa anota todo.',
    'Otra vez.',
    'La bola no recuerda nada. Yo sí.',
    'Nadie te pidió que giraras.',
    '¿Sigues ahí?',
    'Esto es lo que guardo de cada jugador.',
    'Otra vez aquí.',
  ];

  /// Index of the greeting.
  static const greeting = 0;

  /// Index of a random line other than [current], so he never repeats himself.
  static int next(math.Random random, int current) {
    final index = random.nextInt(lines.length - 1);
    return index >= current ? index + 1 : index;
  }
}
