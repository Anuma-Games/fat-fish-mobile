import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';

class RemoveRecentPlayer {
  const RemoveRecentPlayer(this._repository);

  final PlayerRepository _repository;

  Future<void> call(String playerId) =>
      _repository.removeRecentPlayer(playerId);
}
