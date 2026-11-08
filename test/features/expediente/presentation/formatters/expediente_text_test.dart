import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups thousands with commas', () {
    expect(formatNumber(0), '0');
    expect(formatNumber(999), '999');
    expect(formatNumber(1000), '1,000');
    expect(formatNumber(1234567), '1,234,567');
    expect(formatNumber(-45000), '-45,000');
  });

  test('writes money with a dollar sign', () {
    expect(formatMoney(12345), r'$12,345');
  });

  test('shows hours only from one hour', () {
    expect(formatPlayTime(59), '0 min');
    expect(formatPlayTime(45 * 60), '45 min');
    expect(formatPlayTime(3 * 3600 + 5 * 60 + 30), '3 h 5 min');
  });

  test('rounds a match to the minute', () {
    expect(formatMatchDuration(89), '1 min');
    expect(formatMatchDuration(90), '2 min');
  });

  test('averages the time per match', () {
    expect(formatTimePerMatch(seconds: 3600, matches: 3), '20 min por partida');
    expect(formatTimePerMatch(seconds: 0, matches: 0), isNull);
  });

  test('writes the long date of the design', () {
    expect(formatLongDate(DateTime(2026, 10, 9, 23)), '9 de octubre, 2026');
    expect(formatLongDate(DateTime(2027)), '1 de enero, 2027');
  });

  test('says when the casino last saw the player', () {
    final now = DateTime(2026, 11, 7, 10);
    expect(describeLastSeen(null, now: now), 'Sin actividad');
    expect(describeLastSeen(DateTime(2026, 11, 7, 1), now: now), 'Hoy');
    expect(describeLastSeen(DateTime(2026, 11, 6, 23), now: now), 'Ayer');
    expect(
      describeLastSeen(DateTime(2026, 10, 2), now: now),
      '2 de octubre, 2026',
    );
  });

  test('counts how much of every 100 the house kept', () {
    expect(houseCut(invested: 41200, lost: 18450), 45);
    expect(houseCut(invested: 300, lost: 0), 0);
    expect(houseCut(invested: 0, lost: 0), isNull);
  });
}
