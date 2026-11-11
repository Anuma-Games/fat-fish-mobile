import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/network/cached_api.dart';
import 'package:fat_fish_mobile/features/ranking/data/models/ranking_dto.dart';

/// The ranking from the API, or its last copy on the device without connection.
class RankingRemoteDataSource {
  const RankingRemoteDataSource(this._api);

  final CachedApi _api;

  Future<RankingDto> getRanking({
    required int page,
    required int size,
    String? playerId,
  }) async {
    final (:json, :savedAt) = await _api.getJson(
      '/api/pwa/ranking',
      query: {'pagina': '$page', 'tamano': '$size', 'jugadorId': ?playerId},
    );
    // A body with another shape becomes an ApiException, so the screen shows an
    // error instead of staying on the spinner.
    try {
      return RankingDto.fromJson(
        json as Map<String, Object?>,
        savedAt: savedAt,
      );
    } on TypeError {
      throw const UnexpectedResponseException();
    } on FormatException {
      throw const UnexpectedResponseException();
    }
  }
}
