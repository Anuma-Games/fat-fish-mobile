import 'package:drift/drift.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';

import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_local_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_remote_data_source.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  const PlayerRepositoryImpl({required this._remote, required this._local});

  final PlayerRemoteDataSource _remote;
  final PlayerLocalDataSource _local;

  @override
  Future<List<PlayerSummary>> searchPlayers(String query) async {
    final dtos = await _remote.searchPlayers(query);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<PlayerSummary?> getMyPlayer() async {
    final row = await _local.readMyPlayer();
    if (row == null) return null;
    return PlayerSummary(
      id: row.playerId,
      alias: row.alias,
      lastActivity: row.lastActivity,
    );
  }

  @override
  Future<void> saveMyPlayer(PlayerSummary player) => _local.saveMyPlayer(
    MyPlayersCompanion.insert(
      playerId: player.id,
      alias: player.alias,
      lastActivity: Value(player.lastActivity),
    ),
  );

  @override
  Future<void> clearMyPlayer() => _local.clearMyPlayer();

  @override
  Future<List<PlayerSummary>> getRecentPlayers() async {
    final rows = await _local.readRecentPlayers(recentLimit);
    return [
      for (final row in rows)
        PlayerSummary(
          id: row.playerId,
          alias: row.alias,
          lastActivity: row.lastActivity,
        ),
    ];
  }

  @override
  Future<void> addRecentPlayer(PlayerSummary player) => _local.saveRecentPlayer(
    RecentPlayersCompanion.insert(
      playerId: player.id,
      alias: player.alias,
      lastActivity: Value(player.lastActivity),
      viewedAt: DateTime.now().microsecondsSinceEpoch,
    ),
    recentLimit,
  );

  @override
  Future<void> removeRecentPlayer(String playerId) =>
      _local.deleteRecentPlayer(playerId);
}
