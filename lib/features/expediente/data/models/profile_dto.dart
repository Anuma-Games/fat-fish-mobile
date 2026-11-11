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
    this.savedAt,
  });

  /// [savedAt] is the date of a copy read from the device; null for a fresh answer.
  factory ProfileDto.fromJson(Map<String, Object?> json, {DateTime? savedAt}) {
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
      savedAt: savedAt,
    );
  }

  final String jugadorId;
  final String alias;
  final DateTime creadoEn;
  final DateTime? ultimaActividad;
  final ProfileStats estadisticas;
  final DateTime generadoEn;
  final DateTime? savedAt;

  PlayerProfile toEntity() => PlayerProfile(
    id: jugadorId,
    alias: alias,
    createdAt: creadoEn,
    lastActivity: ultimaActividad,
    stats: estadisticas,
    generatedAt: generadoEn,
    savedAt: savedAt,
  );
}
