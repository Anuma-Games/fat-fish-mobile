import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fat_fish_mobile/core/storage/cached_responses_table.dart';
import 'package:fat_fish_mobile/features/ajustes/data/tables/app_settings_table.dart';
import 'package:fat_fish_mobile/features/jugador/data/tables/my_players_table.dart';
import 'package:fat_fish_mobile/features/jugador/data/tables/recent_players_table.dart';

part 'app_database.g.dart';

/// Local cache of API answers. Screens read from here and the network only refreshes it.
/// Each feature adds its tables to the list; a schema change raises [schemaVersion] with a migration.
@DriftDatabase(tables: [MyPlayers, RecentPlayers, CachedResponses, AppSettings])
class AppDatabase extends _$AppDatabase {
  /// Tests pass `NativeDatabase.memory()`; the app uses the file on the device.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fat_fish_cache'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Version 1 had no tables.
      if (from < 2) await m.createTable(myPlayers);
      if (from < 3) await m.createTable(recentPlayers);
      if (from < 4) await m.createTable(cachedResponses);
      if (from < 5) await m.createTable(appSettings);
    },
  );
}
