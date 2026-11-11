import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';

class GetRanking {
  const GetRanking(this._repository);

  final RankingRepository _repository;

  Future<Ranking> call({required int page, String? playerId}) =>
      _repository.getRanking(page: page, playerId: playerId);
}
