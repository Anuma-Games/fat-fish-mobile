import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/ranking/data/models/ranking_dto.dart';

class RankingRemoteDataSource {
  const RankingRemoteDataSource(this._api);

  final ApiClient _api;

  Future<RankingDto> getRanking({
    required int page,
    required int size,
    String? playerId,
  }) async {
    final json = await _api.getJson(
      '/api/pwa/ranking',
      query: {'pagina': '$page', 'tamano': '$size', 'jugadorId': ?playerId},
    );
    // A body with another shape becomes an ApiException, so the screen shows an
    // error instead of staying on the spinner.
    try {
      return RankingDto.fromJson(json as Map<String, Object?>);
    } on TypeError {
      throw const UnexpectedResponseException();
    } on FormatException {
      throw const UnexpectedResponseException();
    }
  }
}
