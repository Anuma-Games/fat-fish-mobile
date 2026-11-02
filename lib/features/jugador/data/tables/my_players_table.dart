import 'package:drift/drift.dart';

/// The player chosen on this device. Holds at most one row.
@DataClassName('MyPlayerRow')
class MyPlayers extends Table {
  TextColumn get playerId => text()();
  TextColumn get alias => text()();
  DateTimeColumn get lastActivity => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {playerId};
}
