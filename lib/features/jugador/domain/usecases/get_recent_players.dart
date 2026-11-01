import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';

class GetRecentPlayers {
  const GetRecentPlayers(this._repository);

  final PlayerRepository _repository;

  Future<List<PlayerSummary>> call() => _repository.getRecentPlayers();
}
