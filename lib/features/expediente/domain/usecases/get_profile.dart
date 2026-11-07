import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';

class GetProfile {
  const GetProfile(this._repository);

  final ExpedienteRepository _repository;

  Future<PlayerProfile> call(String playerId) =>
      _repository.getProfile(playerId);
}
