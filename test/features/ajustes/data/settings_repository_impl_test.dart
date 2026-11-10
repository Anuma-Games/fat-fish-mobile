import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/data/datasources/settings_local_data_source.dart';
import 'package:fat_fish_mobile/features/ajustes/data/repositories/settings_repository_impl.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(local: SettingsLocalDataSource(db));
  });
  tearDown(() => db.close());

  test('starts with every sound off, volume at 6 and vibration on', () async {
    final settings = await repository.getSettings();

    expect(settings, const Settings());
    expect(settings.ambienceOn, isFalse);
    expect(settings.tableSoundsOn, isFalse);
    expect(settings.volume, 6);
    expect(settings.vibration, isTrue);
  });

  test('keeps one row with the last saved settings', () async {
    const first = Settings(ambienceOn: true, volume: 3);
    const second = Settings(tableSoundsOn: true, volume: 9, vibration: false);

    await repository.saveSettings(first);
    await repository.saveSettings(second);

    expect(await repository.getSettings(), second);
    expect(await db.select(db.appSettings).get(), hasLength(1));
  });
}
