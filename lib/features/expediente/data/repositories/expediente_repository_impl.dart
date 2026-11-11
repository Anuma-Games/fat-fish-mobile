import 'package:fat_fish_mobile/features/expediente/data/datasources/expediente_remote_data_source.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';

class ExpedienteRepositoryImpl implements ExpedienteRepository {
  const ExpedienteRepositoryImpl({required this._remote});

  final ExpedienteRemoteDataSource _remote;

  @override
  Future<PlayerProfile> getProfile(String playerId) async =>
      (await _remote.getProfile(playerId)).toEntity();

  @override
  Future<MatchPage> getMatches(
    String playerId, {
    required int page,
    int size = matchPageSize,
  }) async =>
      (await _remote.getMatches(playerId, page: page, size: size)).toEntity();
}
