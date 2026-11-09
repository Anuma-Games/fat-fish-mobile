import 'package:fat_fish_mobile/core/storage/app_database.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._db);

  /// The only row of the table.
  static const rowId = 1;

  final AppDatabase _db;

  Future<AppSettingsRow?> read() => (_db.select(
    _db.appSettings,
  )..where((row) => row.id.equals(rowId))).getSingleOrNull();

  Future<void> save(AppSettingsCompanion row) =>
      _db.into(_db.appSettings).insertOnConflictUpdate(row);
}
