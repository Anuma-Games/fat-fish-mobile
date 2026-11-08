import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';

/// Body of `GET /api/pwa/perfil` (ProfileDto in the API).
class ProfileDto {
  const ProfileDto({
    required this.jugadorId,
    required this.alias,
    required this.creadoEn,
    this.ultimaActividad,
    required this.estadisticas,
    required this.generadoEn,
  });

  factory ProfileDto.fromJson(Map<String, Object?> json) {
    final stats = json['estadisticas'] as Map<String, Object?>;
    return ProfileDto(
      jugadorId: json['jugadorId'] as String,
      alias: json['alias'] as String,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
      ultimaActividad: switch (json['ultimaActividad']) {
        final String value => DateTime.parse(value),
        _ => null,
      },
      estadisticas: ProfileStats(
        totalMatches: stats['partidasTotales'] as int,
        matchesWon: stats['partidasGanadas'] as int,
        moneyInvested: stats['totalInvertido'] as int,
        moneyLost: stats['totalPerdido'] as int,
        longestLosingStreak: stats['rachaDerrotasMax'] as int,
        secondsPlayed: stats['tiempoJugadoSeg'] as int,
      ),
      generadoEn: DateTime.parse(json['generadoEn'] as String),
    );
  }

  final String jugadorId;
  final String alias;
  final DateTime creadoEn;
  final DateTime? ultimaActividad;
  final ProfileStats estadisticas;
  final DateTime generadoEn;

  PlayerProfile toEntity() => PlayerProfile(
    id: jugadorId,
    alias: alias,
    createdAt: creadoEn,
    lastActivity: ultimaActividad,
    stats: estadisticas,
    generatedAt: generadoEn,
  );
}
