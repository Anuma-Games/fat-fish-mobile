import 'package:drift/drift.dart';

/// Players tapped in the search results, newest first. Holds at most five rows.
@DataClassName('RecentPlayerRow')
class RecentPlayers extends Table {
  TextColumn get playerId => text()();
  TextColumn get alias => text()();
  DateTimeColumn get lastActivity => dateTime().nullable()();

  /// Microseconds since epoch: Drift stores DateTime in whole seconds, and two taps
  /// in the same second would tie and drop the wrong row.
  IntColumn get viewedAt => integer()();

  @override
  Set<Column> get primaryKey => {playerId};
}
