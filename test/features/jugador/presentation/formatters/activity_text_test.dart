import 'package:fat_fish_mobile/features/jugador/presentation/formatters/activity_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Local times, so the tests do not depend on the machine's time zone.
  final now = DateTime(2026, 10, 30, 10);

  String describe(DateTime? last) => describeActivity(last, now: now);

  test('says when there is no activity', () {
    expect(describe(null), 'Sin actividad');
  });

  test('counts calendar days, not 24 hour periods', () {
    expect(describe(DateTime(2026, 10, 30, 0, 5)), 'Activo hoy');
    expect(describe(DateTime(2026, 10, 29, 23)), 'Activo ayer');
    expect(describe(DateTime(2026, 10, 28, 11)), 'Activo hace 2 días');
  });

  test('switches to weeks after six days', () {
    expect(describe(DateTime(2026, 10, 24)), 'Activo hace 6 días');
    expect(describe(DateTime(2026, 10, 23)), 'Activo hace 1 semana');
    expect(describe(DateTime(2026, 10, 16)), 'Activo hace 2 semanas');
    expect(describe(DateTime(2026, 10, 1)), 'Activo hace 4 semanas');
  });

  test('shows the date after a month', () {
    expect(describe(DateTime(2026, 9, 30)), 'Activo el 30/09/2026');
  });

  test('treats a date in the future as today', () {
    expect(describe(DateTime(2026, 10, 31)), 'Activo hoy');
  });
}
