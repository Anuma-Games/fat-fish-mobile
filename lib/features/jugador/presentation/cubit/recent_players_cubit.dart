import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/add_recent_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_recent_players.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/remove_recent_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Players tapped in the results, newest first. Shown while the search field is empty.
class RecentPlayersCubit extends Cubit<List<PlayerSummary>> {
  RecentPlayersCubit({
    required this._getRecentPlayers,
    required this._addRecentPlayer,
    required this._removeRecentPlayer,
  }) : super(const []);

  final GetRecentPlayers _getRecentPlayers;
  final AddRecentPlayer _addRecentPlayer;
  final RemoveRecentPlayer _removeRecentPlayer;

  Future<void> load() async => emit(await _getRecentPlayers());

  Future<void> add(PlayerSummary player) async {
    await _addRecentPlayer(player);
    await load();
  }

  /// Removes the row at once: Dismissible needs it gone from the list in the same frame.
  Future<void> remove(String playerId) async {
    emit([
      for (final player in state)
        if (player.id != playerId) player,
    ]);
    await _removeRecentPlayer(playerId);
  }
}
