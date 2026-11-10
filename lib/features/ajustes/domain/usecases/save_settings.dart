import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/repositories/settings_repository.dart';

class SaveSettings {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<void> call(Settings settings) => _repository.saveSettings(settings);
}
