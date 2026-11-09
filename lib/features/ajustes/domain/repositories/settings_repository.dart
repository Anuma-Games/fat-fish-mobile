import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';

/// Settings saved on the device, so they are the same when the app opens again.
abstract interface class SettingsRepository {
  Future<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
}
