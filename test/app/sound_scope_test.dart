import 'package:fat_fish_mobile/app/sound_scope.dart';
import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/repositories/settings_repository.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/get_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/save_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _SavedSettings implements SettingsRepository {
  Settings value = const Settings();
  @override
  Future<Settings> getSettings() async => value;
  @override
  Future<void> saveSettings(Settings settings) async => value = settings;
}

class _RecordingSound extends SilentTableSound {
  final configurations = <({bool ambience, bool effects, double volume})>[];
  int pauses = 0;
  int resumes = 0;
  @override
  Future<void> configure({
    required bool ambience,
    required bool effects,
    required double volume,
  }) async => configurations.add((
    ambience: ambience,
    effects: effects,
    volume: volume,
  ));
  @override
  Future<void> pause() async => pauses++;
  @override
  Future<void> resume() async => resumes++;
}

void main() {
  late SettingsCubit settings;
  late _RecordingSound sound;
  setUp(() {
    final saved = _SavedSettings();
    settings = SettingsCubit(
      getSettings: GetSettings(saved),
      saveSettings: SaveSettings(saved),
    );
    sound = _RecordingSound();
  });
  tearDown(() => settings.close());

  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
    RepositoryProvider<TableSound>.value(
      value: sound,
      child: BlocProvider.value(
        value: settings,
        child: const SoundScope(child: SizedBox()),
      ),
    ),
  );

  testWidgets('first visit keeps both sound channels off', (tester) async {
    await mount(tester);
    expect(sound.configurations.single, (
      ambience: false,
      effects: false,
      volume: 0.6,
    ));
  });

  testWidgets('settings reach the sound, including zero and full volume', (
    tester,
  ) async {
    await mount(tester);
    await settings.toggleAmbience();
    await settings.toggleTableSounds();
    await settings.setVolume(10);
    await tester.pump();
    expect(sound.configurations.last, (
      ambience: true,
      effects: true,
      volume: 1.0,
    ));
    await settings.setVolume(0);
    await tester.pump();
    expect(sound.configurations.last.volume, 0);
    await settings.toggleAmbience();
    await settings.toggleTableSounds();
    await tester.pump();
    expect(sound.configurations.last, (
      ambience: false,
      effects: false,
      volume: 0.0,
    ));
  });

  testWidgets('background pauses sound and return keeps the saved choices', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await mount(tester);
    await settings.toggleAmbience();
    await settings.setVolume(8);
    await tester.pump();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(sound.pauses, 1);
    expect(sound.resumes, 0);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(sound.resumes, 1);
    expect(settings.state.ambienceOn, isTrue);
    expect(settings.state.volume, 8);
  });
}
