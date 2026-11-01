import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';

/// Players from the API, the one chosen on this device and the recent ones.
/// Network failures surface as `ApiException` (see core/network).
abstract interface class PlayerRepository {
  /// Exact id (digits only) or alias containing [query]; at most 20, best match first.
  Future<List<PlayerSummary>> searchPlayers(String query);

  /// The player chosen on this device, or null if none yet.
  Future<PlayerSummary?> getMyPlayer();

  /// Replaces the chosen player.
  Future<void> saveMyPlayer(PlayerSummary player);

  Future<void> clearMyPlayer();

  /// Players tapped in the results on this device, newest first (at most [recentLimit]).
  Future<List<PlayerSummary>> getRecentPlayers();

  /// Moves [player] to the top of the recent players, dropping the oldest past the limit.
  Future<void> addRecentPlayer(PlayerSummary player);

  Future<void> removeRecentPlayer(String playerId);
}

/// Recent players kept on the device: five on screen plus your player, which the
/// screen hides because it already shows in the card.
const recentLimit = 6;
