import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';

class ClearMyPlayer {
  const ClearMyPlayer(this._repository);

  final PlayerRepository _repository;

  Future<void> call() => _repository.clearMyPlayer();
}
