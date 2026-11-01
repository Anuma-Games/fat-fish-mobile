/// Short text for the last activity of a player, relative to [now].
/// `lastActivity` changes when the player sends a match or signs in, so it says
/// "activo" and never "jugó". Null means the player has done neither yet.
String describeActivity(DateTime? lastActivity, {required DateTime now}) {
  if (lastActivity == null) return 'Sin actividad';

  final days = _calendarDaysBetween(lastActivity, now);
  return switch (days) {
    // A clock slightly ahead on the server can give a date in the future.
    <= 0 => 'Activo hoy',
    1 => 'Activo ayer',
    < 7 => 'Activo hace $days días',
    < 14 => 'Activo hace 1 semana',
    < 30 => 'Activo hace ${days ~/ 7} semanas',
    _ => 'Activo el ${formatDate(lastActivity)}',
  };
}

/// Days between the two local dates, ignoring the time: 23:00 yesterday is 1 day ago.
/// UTC dates avoid the 23 or 25 hour days of daylight saving time.
int _calendarDaysBetween(DateTime from, DateTime to) {
  DateTime dayOf(DateTime date) {
    final local = date.toLocal();
    return DateTime.utc(local.year, local.month, local.day);
  }

  return dayOf(to).difference(dayOf(from)).inDays;
}

/// `dd/mm/aaaa` in the phone's time zone, without pulling in intl for one format.
String formatDate(DateTime date) {
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}
