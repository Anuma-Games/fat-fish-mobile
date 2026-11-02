import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_row.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initialsOf', () {
    test('takes the first letter of the first two words', () {
      expect(initialsOf('Don Ramon'), 'DR');
      expect(initialsOf('el gran pez'), 'EG');
    });

    test('takes the first two letters of a single word', () {
      expect(initialsOf('rk_01'), 'RK');
      expect(initialsOf('ñandú'), 'ÑA');
    });

    test('survives a one-letter or blank alias', () {
      expect(initialsOf('x'), 'X');
      expect(initialsOf('  '), '?');
    });
  });

  group('highlightMatch', () {
    const gold = TextStyle(color: Color(0xFFE8B850));

    List<(String?, TextStyle?)> parts(List<TextSpan> spans) => [
      for (final span in spans) (span.text, span.style),
    ];

    test('paints the first match, ignoring case', () {
      expect(parts(highlightMatch('Don Ramon', 'ram', gold)), [
        ('Don ', null),
        ('Ram', gold),
        ('on', null),
      ]);
    });

    test('leaves the text alone without a match or a query', () {
      expect(parts(highlightMatch('Don Ramon', 'xyz', gold)), [
        ('Don Ramon', null),
      ]);
      expect(parts(highlightMatch('Don Ramon', '', gold)), [
        ('Don Ramon', null),
      ]);
    });
  });

  test(
    'highlightMatch does not break on letters that grow when lowercased',
    () {
      const gold = TextStyle(color: Color(0xFFE8B850));

      final spans = highlightMatch('İzmir Pez', 'pez', gold);

      expect(spans.map((span) => span.text).join(), 'İzmir Pez');
    },
  );
}
