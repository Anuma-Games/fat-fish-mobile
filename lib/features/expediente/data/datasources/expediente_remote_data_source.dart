import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/expediente/data/models/match_page_dto.dart';
import 'package:fat_fish_mobile/features/expediente/data/models/profile_dto.dart';

class ExpedienteRemoteDataSource {
  const ExpedienteRemoteDataSource(this._api);

  final ApiClient _api;

  Future<ProfileDto> getProfile(String playerId) async {
    final json = await _api.getJson('/api/pwa/perfil', query: {'id': playerId});
    return _parse(() => ProfileDto.fromJson(json as Map<String, Object?>));
  }

  Future<MatchPageDto> getMatches(
    String playerId, {
    required int page,
    required int size,
  }) async {
    final json = await _api.getJson(
      '/api/pwa/partidas',
      query: {'id': playerId, 'pagina': '$page', 'tamano': '$size'},
    );
    return _parse(() => MatchPageDto.fromJson(json as Map<String, Object?>));
  }

  /// A body with another shape becomes an ApiException, so the screen shows an
  /// error instead of staying on the spinner.
  T _parse<T>(T Function() fromJson) {
    try {
      return fromJson();
    } on TypeError {
      throw const UnexpectedResponseException();
    } on FormatException {
      throw const UnexpectedResponseException();
    }
  }
}
