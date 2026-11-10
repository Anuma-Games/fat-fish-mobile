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

  /// Index of a random line after a spin: never the greeting, and never [current], so
  /// he does not repeat himself.
  static int next(math.Random random, int current) {
    final choices = [
      for (var i = 0; i < lines.length; i++)
        if (i != greeting && i != current) i,
    ];
    return choices[random.nextInt(choices.length)];
  }
}
