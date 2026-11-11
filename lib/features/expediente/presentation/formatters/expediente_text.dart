import 'package:fat_fish_mobile/features/jugador/presentation/formatters/activity_text.dart';

/// 12345 → "12,345", the way the PWA shows numbers. Without intl for one format.
String formatNumber(int value) {
  final digits = value.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+$)'),
    (_) => ',',
  );
  return value < 0 ? '-$grouped' : grouped;
}

/// Fictitious money of the game, without cents: "$12,345".
String formatMoney(int value) => '\$${formatNumber(value)}';

/// Total time at the table: "45 min", or "3 h 5 min" from one hour.
String formatPlayTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return hours > 0 ? '$hours h $minutes min' : '$minutes min';
}

/// Length of one match, rounded to the minute: "18 min".
String formatMatchDuration(int seconds) => '${(seconds / 60).round()} min';

/// Average length of a match: "18 min por partida". Null without matches.
String? formatTimePerMatch({required int seconds, required int matches}) =>
    matches == 0
    ? null
    : '${formatMatchDuration(seconds ~/ matches)} por partida';

const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "9 de octubre, 2026" in the phone's time zone, the date format of the design.
String formatLongDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} de ${_months[local.month - 1]}, ${local.year}';
}

/// When a copy was saved on the device: "3 de noviembre, 2026, a las 18:42".
String formatSavedAt(DateTime date) {
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${formatLongDate(local)}, a las ${two(local.hour)}:${two(local.minute)}';
}

/// Last time the casino saw the player: "Hoy", "Ayer" or the date.
String describeLastSeen(DateTime? lastActivity, {required DateTime now}) {
  if (lastActivity == null) return 'Sin actividad';
  return switch (calendarDaysBetween(lastActivity, now)) {
    <= 0 => 'Hoy',
    1 => 'Ayer',
    _ => formatLongDate(lastActivity),
  };
}

/// Of every $100 the player put on the table, how many the house kept (0 to 100).
/// Null when nothing was invested yet.
int? houseCut({required int invested, required int lost}) =>
    invested <= 0 ? null : (lost * 100 / invested).round().clamp(0, 100);
