import 'package:drift/drift.dart' show Value;
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/data/datasources/settings_local_data_source.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this._local});

  final SettingsLocalDataSource _local;

  @override
  Future<Settings> getSettings() async {
    final row = await _local.read();
    if (row == null) return const Settings();
    return Settings(
      ambienceOn: row.ambienceOn,
      tableSoundsOn: row.tableSoundsOn,
      volume: row.volume,
      vibration: row.vibration,
    );
  }

  @override
  Future<void> saveSettings(Settings settings) => _local.save(
    AppSettingsCompanion.insert(
      id: const Value(SettingsLocalDataSource.rowId),
      ambienceOn: settings.ambienceOn,
      tableSoundsOn: settings.tableSoundsOn,
      volume: settings.volume,
      vibration: settings.vibration,
    ),
  );
}
