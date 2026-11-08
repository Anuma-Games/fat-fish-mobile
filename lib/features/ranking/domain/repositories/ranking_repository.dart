import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';

/// World ranking, read from the API. Failures surface as `ApiException`.
abstract interface class RankingRepository {
  /// Page [page] (from 0) of the top 50. With [playerId], the page also brings the
  /// place of that player.
  Future<Ranking> getRanking({required int page, String? playerId});
}

/// Places per page: the top 50 fits in 5 pages.
const rankingPageSize = 10;
