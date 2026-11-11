import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/formatters/activity_text.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:flutter/material.dart';

/// What the right edge of a [PlayerRow] shows.
enum PlayerRowBadge { none, recent, mine }

/// Avatar, alias with the matching text in gold, number and activity, and a badge.
class PlayerRow extends StatelessWidget {
  const PlayerRow({
    super.key,
    required this.player,
    required this.onTap,
    this.highlight = '',
    this.badge = PlayerRowBadge.none,
  });

  final PlayerSummary player;
  final VoidCallback onTap;

  /// Text typed in the search field; its first match in the alias is painted gold.
  final String highlight;
  final PlayerRowBadge badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aliasStyle = textTheme.headlineSmall;
    final mine = badge == PlayerRowBadge.mine;

    // Your player gets the felt and gold of the card above, so it stands out in a list.
    return AnimatedContainer(
      duration: motionDuration(context, FatFishMotion.base),
      curve: FatFishMotion.curve,
      decoration: BoxDecoration(
        color: mine
            ? FatFishColors.felt800
            : FatFishColors.felt800.withValues(alpha: 0),
        borderRadius: const BorderRadius.all(FatFishRadius.card),
        border: Border.all(
          color: mine
              ? FatFishColors.gold400
              : FatFishColors.gold400.withValues(alpha: 0),
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(FatFishRadius.card),
        onTap: mine ? null : onTap,
        child: Padding(
          // Same side inset as the card content, so avatars line up down the page.
          padding: const EdgeInsets.symmetric(
            horizontal: FatFishSpacing.s4,
            vertical: FatFishSpacing.s2,
          ),
          child: Row(
            children: [
              PlayerAvatar(player),
              const SizedBox(width: FatFishSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Identity line: alias and number together, so equal aliases
                    // tell apart at a glance. A long alias shrinks; the number never does.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              style: aliasStyle,
                              children: highlightMatch(
                                player.alias,
                                highlight,
                                aliasStyle?.copyWith(
                                  color: FatFishColors.gold400,
                                ),
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: FatFishSpacing.s2),
                        Text(
                          '#${player.id}',
                          style: textTheme.bodySmall?.copyWith(
                            // A number typed in the search matches this, not the alias.
                            color: highlight == player.id
                                ? FatFishColors.gold400
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      describeActivity(
                        player.lastActivity,
                        now: DateTime.now(),
                      ),
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FatFishSpacing.s3),
              // Fixed width, so the text column lines up with or without a badge.
              SizedBox.square(
                dimension: 24,
                child: AnimatedSwitcher(
                  duration: motionDuration(context, FatFishMotion.fast),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: switch (badge) {
                    PlayerRowBadge.none => const SizedBox.shrink(),
                    PlayerRowBadge.recent => const PixelIcon(
                      PixelIcons.clock,
                      key: ValueKey(PlayerRowBadge.recent),
                      color: FatFishColors.fog400,
                    ),
                    PlayerRowBadge.mine => const PixelIcon(
                      PixelIcons.check,
                      key: ValueKey(PlayerRowBadge.mine),
                      color: FatFishColors.gold400,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Splits [text] around the first case-insensitive match of [query].
List<TextSpan> highlightMatch(
  String text,
  String query,
  TextStyle? matchStyle,
) {
  final lower = text.toLowerCase();
  // Some letters change length when lowercased ("İ" becomes two code units);
  // then the indexes would not match [text], so nothing is painted.
  final start = query.isEmpty || lower.length != text.length
      ? -1
      : lower.indexOf(query.toLowerCase());
  if (start < 0) return [TextSpan(text: text)];
  final end = start + query.length;
  return [
    TextSpan(text: text.substring(0, start)),
    TextSpan(text: text.substring(start, end), style: matchStyle),
    TextSpan(text: text.substring(end)),
  ];
}
