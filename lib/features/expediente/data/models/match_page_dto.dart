import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';

/// Body of `GET /api/pwa/partidas`: `PwaPage<MatchDto>` in the API.
class MatchPageDto {
  const MatchPageDto({
    required this.contenido,
    required this.pagina,
    required this.totalElementos,
    required this.ultima,
    this.savedAt,
  });

  /// [savedAt] is the date of a copy read from the device; null for a fresh answer.
  factory MatchPageDto.fromJson(
    Map<String, Object?> json, {
    DateTime? savedAt,
  }) => MatchPageDto(
    contenido: (json['contenido'] as List<Object?>)
        .map((item) => _matchFromJson(item as Map<String, Object?>))
        .toList(),
    pagina: json['pagina'] as int,
    totalElementos: json['totalElementos'] as int,
    ultima: json['ultima'] as bool,
    savedAt: savedAt,
  );

  final List<PlayedMatch> contenido;
  final int pagina;
  final int totalElementos;
  final bool ultima;
  final DateTime? savedAt;

  MatchPage toEntity() => MatchPage(
    matches: contenido,
    page: pagina,
    totalMatches: totalElementos,
    isLast: ultima,
    savedAt: savedAt,
  );

  /// MatchDto in the API. `creadaEn` carries the date the match ended.
  static PlayedMatch _matchFromJson(Map<String, Object?> json) => PlayedMatch(
    id: json['id'] as String,
    result: switch (json['resultado']) {
      'VICTORIA' => MatchResult.victory,
      'DERROTA' => MatchResult.defeat,
      'ABANDONO' => MatchResult.abandoned,
      final other => throw FormatException('Resultado desconocido: $other'),
    },
    roundReached: json['rondaAlcanzada'] as int,
    score: json['puntaje'] as int,
    moneyInvested: json['dineroInvertido'] as int,
    moneyWon: json['dineroGanado'] as int,
    moneyLost: json['dineroPerdido'] as int,
    durationSeconds: json['duracionSeg'] as int,
    playedAt: DateTime.parse(json['creadaEn'] as String),
  );
}
