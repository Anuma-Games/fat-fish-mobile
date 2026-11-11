import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';

class AddRecentPlayer {
  const AddRecentPlayer(this._repository);

  final PlayerRepository _repository;

  Future<void> call(PlayerSummary player) =>
      _repository.addRecentPlayer(player);
}
