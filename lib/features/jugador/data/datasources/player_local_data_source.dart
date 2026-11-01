import 'package:drift/drift.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';

class PlayerLocalDataSource {
  const PlayerLocalDataSource(this._db);

  final AppDatabase _db;

  Future<MyPlayerRow?> readMyPlayer() =>
      _db.select(_db.myPlayers).getSingleOrNull();

  /// Deletes and inserts in one transaction, so the table never holds two players.
  Future<void> saveMyPlayer(MyPlayersCompanion row) =>
      _db.transaction(() async {
        await _db.delete(_db.myPlayers).go();
        await _db.into(_db.myPlayers).insert(row);
      });

  Future<void> clearMyPlayer() => _db.delete(_db.myPlayers).go();

  Future<List<RecentPlayerRow>> readRecentPlayers(int limit) =>
      (_db.select(_db.recentPlayers)
            ..orderBy([(t) => OrderingTerm.desc(t.viewedAt)])
            ..limit(limit))
          .get();

  /// Upserts [row] and deletes every row past the newest [limit] in one transaction.
  Future<void> saveRecentPlayer(RecentPlayersCompanion row, int limit) =>
      _db.transaction(() async {
        await _db.into(_db.recentPlayers).insertOnConflictUpdate(row);
        final keep = await readRecentPlayers(limit);
        await (_db.delete(
          _db.recentPlayers,
        )..where((t) => t.playerId.isNotIn(keep.map((r) => r.playerId)))).go();
      });

  Future<void> deleteRecentPlayer(String playerId) => (_db.delete(
    _db.recentPlayers,
  )..where((t) => t.playerId.equals(playerId))).go();
}
