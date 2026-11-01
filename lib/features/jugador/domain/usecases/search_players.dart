import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';

class SearchPlayers {
  const SearchPlayers(this._repository);

  final PlayerRepository _repository;

  Future<List<PlayerSummary>> call(String query) =>
      _repository.searchPlayers(query);
}
