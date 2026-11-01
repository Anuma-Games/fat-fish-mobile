import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';

/// Item of `GET /api/pwa/jugadores` (PlayerSummaryDto in the API).
class PlayerSummaryDto {
  const PlayerSummaryDto({
    required this.jugadorId,
    required this.alias,
    this.ultimaActividad,
  });

  factory PlayerSummaryDto.fromJson(Map<String, Object?> json) =>
      PlayerSummaryDto(
        jugadorId: json['jugadorId'] as String,
        alias: json['alias'] as String,
        ultimaActividad: switch (json['ultimaActividad']) {
          final String value => DateTime.parse(value),
          _ => null,
        },
      );

  final String jugadorId;
  final String alias;
  final DateTime? ultimaActividad;

  PlayerSummary toEntity() =>
      PlayerSummary(id: jugadorId, alias: alias, lastActivity: ultimaActividad);
}
