import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opens an in-memory database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final row = await db.customSelect('SELECT 1 AS one').getSingle();

    expect(row.read<int>('one'), 1);
  });

  test('upgrades a version 1 database to the current tables', () async {
    // Version 1 shipped with no tables; the upgrade must create all of them.
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw.execute('PRAGMA user_version = 1;'),
      ),
    );
    addTearDown(db.close);

    expect(await db.select(db.myPlayers).get(), isEmpty);
    expect(await db.select(db.recentPlayers).get(), isEmpty);
    expect(await db.select(db.cachedResponses).get(), isEmpty);
    expect(await db.select(db.appSettings).get(), isEmpty);
  });
}
