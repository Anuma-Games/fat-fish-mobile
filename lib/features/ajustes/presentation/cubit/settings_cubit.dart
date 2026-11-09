import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/get_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/save_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The settings of the app. Lives above the router: the top bar, the bottom bar, the
/// table and the sound all read it. Starts with the defaults until the saved ones load.
class SettingsCubit extends Cubit<Settings> {
  SettingsCubit({required this._getSettings, required this._saveSettings})
    : super(const Settings());

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> load() async => emit(await _getSettings());

  Future<void> toggleAmbience() =>
      _change(state.copyWith(ambienceOn: !state.ambienceOn));

  Future<void> toggleTableSounds() =>
      _change(state.copyWith(tableSoundsOn: !state.tableSoundsOn));

  Future<void> setVolume(int volume) =>
      _change(state.copyWith(volume: volume.clamp(0, Settings.maxVolume)));

  Future<void> toggleVibration() =>
      _change(state.copyWith(vibration: !state.vibration));

  /// The screen changes at once; the device saves behind.
  Future<void> _change(Settings settings) async {
    if (settings == state) return;
    emit(settings);
    await _saveSettings(settings);
  }
}
