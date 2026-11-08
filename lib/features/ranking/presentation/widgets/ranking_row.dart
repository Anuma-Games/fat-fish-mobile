import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:flutter/material.dart';

/// One place of the list: the position on the color of the player, alias, number and score.
class RankingRow extends StatelessWidget {
  const RankingRow(this.entry, {super.key});

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FatFishSpacing.s4,
          vertical: FatFishSpacing.s2,
        ),
        child: Row(
          children: [
            PositionSquare(
              position: entry.position,
              color: PlayerAvatar.colorFor(entry.playerId),
            ),
            const SizedBox(width: FatFishSpacing.s3),
            Expanded(
              child: AliasLine(alias: entry.alias, id: entry.playerId),
            ),
            const SizedBox(width: FatFishSpacing.s2),
            Text(formatNumber(entry.score), style: textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

/// 40 × 40 square with a place of the ranking.
class PositionSquare extends StatelessWidget {
  const PositionSquare({
    super.key,
    required this.position,
    required this.color,
  });

  /// Null when the player has no place yet.
  final int? position;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: position == null ? 'Sin lugar' : 'Lugar $position',
      excludeSemantics: true,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(FatFishRadius.card),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            position == null ? '-' : formatNumber(position!),
            maxLines: 1,
            style: const TextStyle(
              fontFamily: FatFishFonts.display,
              fontSize: 22,
              color: FatFishColors.cream100,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias in big letters and the player number next to it, since aliases repeat.
class AliasLine extends StatelessWidget {
  const AliasLine({super.key, required this.alias, required this.id});

  final String alias;
  final String id;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            alias,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall,
          ),
        ),
        const SizedBox(width: FatFishSpacing.s2),
        Text('#$id', style: textTheme.bodySmall),
      ],
    );
  }
}
