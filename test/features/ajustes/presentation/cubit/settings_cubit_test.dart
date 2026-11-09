import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/data/datasources/settings_local_data_source.dart';
import 'package:fat_fish_mobile/features/ajustes/data/repositories/settings_repository_impl.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/get_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/save_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  SettingsCubit build() {
    final repository = SettingsRepositoryImpl(
      local: SettingsLocalDataSource(db),
    );
    return SettingsCubit(
      getSettings: GetSettings(repository),
      saveSettings: SaveSettings(repository),
    );
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('changes are remembered by the next start', () async {
    final first = build();
    await first.load();
    await first.toggleAmbience();
    await first.toggleTableSounds();
    await first.setVolume(8);
    await first.toggleVibration();
    await first.close();

    final next = build();
    await next.load();

    expect(
      next.state,
      const Settings(
        ambienceOn: true,
        tableSoundsOn: true,
        volume: 8,
        vibration: false,
      ),
    );
    await next.close();
  });

  test('the volume stays between 0 and 10', () async {
    final cubit = build();

    await cubit.setVolume(14);
    expect(cubit.state.volume, Settings.maxVolume);

    await cubit.setVolume(-2);
    expect(cubit.state.volume, 0);
    await cubit.close();
  });
}
