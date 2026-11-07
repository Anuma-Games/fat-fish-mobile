import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';

class GetMatches {
  const GetMatches(this._repository);

  final ExpedienteRepository _repository;

  Future<MatchPage> call(String playerId, {required int page}) =>
      _repository.getMatches(playerId, page: page);
}
