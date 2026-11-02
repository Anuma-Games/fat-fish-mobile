import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/jugador/data/models/player_summary_dto.dart';

class PlayerRemoteDataSource {
  const PlayerRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<PlayerSummaryDto>> searchPlayers(String query) async {
    final json = await _api.getJson(
      '/api/pwa/jugadores',
      query: {'busqueda': query},
    );
    // A body with another shape becomes an ApiException, so the screen shows an
    // error instead of staying on the spinner.
    try {
      return (json as List<Object?>)
          .map(
            (item) => PlayerSummaryDto.fromJson(item as Map<String, Object?>),
          )
          .toList();
    } on TypeError {
      throw const UnexpectedResponseException();
    } on FormatException {
      throw const UnexpectedResponseException();
    }
  }
}
