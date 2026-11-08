import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/ranking_row.dart';
import 'package:flutter/material.dart';

/// The place of the saved player, on felt with a gold frame, above the podium.
class MyPlaceCard extends StatelessWidget {
  const MyPlaceCard({super.key, required this.player, this.place});

  final PlayerSummary player;

  /// Null when the player has not won a match yet.
  final RankingEntry? place;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final place = this.place;

    return Semantics(
      container: true,
      label: place == null
          ? 'Tu lugar en el ranking: sin victorias todavía'
          : 'Tu lugar en el ranking: ${place.position}, '
                'con ${formatNumber(place.score)} puntos',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FatFishSpacing.s4,
          vertical: FatFishSpacing.s2,
        ),
        decoration: const BoxDecoration(
          color: FatFishColors.felt800,
          border: Border.fromBorderSide(
            BorderSide(color: FatFishColors.gold400),
          ),
          borderRadius: BorderRadius.all(FatFishRadius.card),
        ),
        child: Row(
          children: [
            PositionSquare(
              position: place?.position,
              color: FatFishColors.gold600,
            ),
            const SizedBox(width: FatFishSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AliasLine(alias: player.alias, id: player.id),
                  Text(
                    place == null
                        ? 'Gana una partida para entrar'
                        : 'Tu mejor partida',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (place != null) ...[
              const SizedBox(width: FatFishSpacing.s2),
              Text(formatNumber(place.score), style: textTheme.headlineSmall),
            ],
          ],
        ),
      ),
    );
  }
}
