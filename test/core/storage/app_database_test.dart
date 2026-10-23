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
}
