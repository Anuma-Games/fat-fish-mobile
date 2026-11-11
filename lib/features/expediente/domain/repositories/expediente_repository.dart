import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';

/// Dossier and match history of a player, read from the API.
/// Failures surface as `ApiException`; an unknown player is a `NotFoundException`.
abstract interface class ExpedienteRepository {
  Future<PlayerProfile> getProfile(String playerId);

  /// Page [page] (from 0) of the history, newest first.
  Future<MatchPage> getMatches(
    String playerId, {
    required int page,
    int size = matchPageSize,
  });
}

/// Matches per page, the same as "Ver más partidas" in the PWA.
const matchPageSize = 10;
