import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';

/// Body of `GET /api/pwa/ranking`: `RankingDto` in the API, a page of `RankingEntryDto`
/// and the place of the player asked for.
class RankingDto {
  const RankingDto({
    required this.contenido,
    required this.pagina,
    required this.totalPaginas,
    this.miPosicion,
  });

  factory RankingDto.fromJson(Map<String, Object?> json) {
    final page = json['pagina'] as Map<String, Object?>;
    return RankingDto(
      contenido: (page['contenido'] as List<Object?>)
          .map((item) => _entryFromJson(item as Map<String, Object?>))
          .toList(),
      pagina: page['pagina'] as int,
      totalPaginas: page['totalPaginas'] as int,
      miPosicion: switch (json['miPosicion']) {
        final Map<String, Object?> entry => _entryFromJson(entry),
        _ => null,
      },
    );
  }

  final List<RankingEntry> contenido;
  final int pagina;
  final int totalPaginas;
  final RankingEntry? miPosicion;

  Ranking toEntity() => Ranking(
    entries: contenido,
    page: pagina,
    totalPages: totalPaginas,
    myPosition: miPosicion,
  );

  static RankingEntry _entryFromJson(Map<String, Object?> json) => RankingEntry(
    position: json['posicion'] as int,
    playerId: json['jugadorId'] as String,
    alias: json['alias'] as String,
    score: json['puntaje'] as int,
    achievedAt: DateTime.parse(json['logradoEn'] as String),
  );
}
