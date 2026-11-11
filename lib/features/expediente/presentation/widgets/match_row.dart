import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:flutter/material.dart';

/// One match of the history: round badge, result, date and length, score and loss.
class MatchRow extends StatelessWidget {
  const MatchRow(
    this.match, {
    super.key,
    this.showInvested = false,
    this.onTap,
  });

  final PlayedMatch match;

  /// The history adds "de $2,350" under the score; the dossier leaves it out.
  final bool showInvested;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FatFishSpacing.s4,
          vertical: FatFishSpacing.s2,
        ),
        child: Row(
          children: [
            RoundBadge(round: match.roundReached, result: match.result),
            const SizedBox(width: FatFishSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resultName(match.result),
                    style: textTheme.headlineSmall,
                  ),
                  Text(
                    '${formatLongDate(match.playedAt)}, '
                    '${formatMatchDuration(match.durationSeconds)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FatFishSpacing.s2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatNumber(match.score)} pts',
                  style: textTheme.headlineSmall?.copyWith(fontSize: 22),
                ),
                if (showInvested)
                  Text(
                    'de ${formatMoney(match.moneyInvested)}',
                    style: textTheme.bodySmall,
                  ),
                if (match.moneyLost > 0) ...[
                  const SizedBox(height: 2),
                  LossChip(match.moneyLost),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

String resultName(MatchResult result) => switch (result) {
  MatchResult.victory => 'Victoria',
  MatchResult.defeat => 'Derrota',
  MatchResult.abandoned => 'Abandono',
};

/// 44 × 44 square with the round reached, colored by the result: felt with a gold
/// frame for a victory, the red for a defeat and plain for an abandoned match.
class RoundBadge extends StatelessWidget {
  const RoundBadge({super.key, required this.round, required this.result});

  final int round;
  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = switch (result) {
      MatchResult.victory => (
        FatFishColors.felt700,
        FatFishColors.gold600,
        FatFishColors.cream100,
      ),
      MatchResult.defeat => (
        FatFishColors.red,
        FatFishColors.red,
        FatFishColors.cream100,
      ),
      MatchResult.abandoned => (
        FatFishColors.bg700,
        FatFishColors.line,
        FatFishColors.fog400,
      ),
    };

    return Semantics(
      label: 'Ronda $round',
      excludeSemantics: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: const BorderRadius.all(FatFishRadius.card),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RONDA',
              style: TextStyle(
                fontFamily: FatFishFonts.label,
                fontSize: 5,
                letterSpacing: 0.5,
                color: foreground,
              ),
            ),
            // Rounds have no limit: a long number shrinks to fit the square.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$round',
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FatFishFonts.display,
                  fontSize: 24,
                  height: 0.9,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Money lost in one match: cream text on the red, since the red only goes as text on paper.
class LossChip extends StatelessWidget {
  const LossChip(this.amount, {super.key});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: FatFishColors.red,
        borderRadius: BorderRadius.all(FatFishRadius.field),
      ),
      child: Text(
        '-${formatMoney(amount)}',
        style: const TextStyle(
          fontFamily: FatFishFonts.body,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 20 / 13,
          color: FatFishColors.cream100,
        ),
      ),
    );
  }
}

/// Translucent panel that holds a list of rows with a line between them.
class RowsPanel extends StatelessWidget {
  const RowsPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FatFishColors.bg700.withValues(alpha: 0.6),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FatFishRadius.card),
        side: BorderSide(color: FatFishColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(height: 1, thickness: 1),
            child,
          ],
        ],
      ),
    );
  }
}
