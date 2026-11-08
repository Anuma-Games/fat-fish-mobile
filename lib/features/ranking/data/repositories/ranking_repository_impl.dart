import 'package:fat_fish_mobile/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  const RankingRepositoryImpl({required this._remote});

  final RankingRemoteDataSource _remote;

  @override
  Future<Ranking> getRanking({required int page, String? playerId}) async =>
      (await _remote.getRanking(
        page: page,
        size: rankingPageSize,
        playerId: playerId,
      )).toEntity();
}
