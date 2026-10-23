import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local cache of API answers. Screens read from here and the network only refreshes it.
/// Each feature adds its tables to the list; a schema change raises [schemaVersion] with a migration.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  /// Tests pass `NativeDatabase.memory()`; the app uses the file on the device.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fat_fish_cache'));

  @override
  int get schemaVersion => 1;
}
