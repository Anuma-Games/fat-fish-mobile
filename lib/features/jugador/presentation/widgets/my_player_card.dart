import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:flutter/material.dart';

/// The chosen player, or what to do when there is none.
/// With a player it turns felt green with a gold border, like the selected tab.
class MyPlayerCard extends StatelessWidget {
  const MyPlayerCard({super.key, required this.player, required this.onClear});

  final PlayerSummary? player;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final player = this.player;
    final chosen = player != null;

    return AnimatedContainer(
      duration: motionDuration(context, FatFishMotion.base),
      curve: FatFishMotion.curve,
      padding: const EdgeInsets.all(FatFishSpacing.s4),
      decoration: BoxDecoration(
        color: chosen ? FatFishColors.felt800 : FatFishColors.bg700,
        borderRadius: const BorderRadius.all(FatFishRadius.card),
        border: Border.all(
          color: chosen ? FatFishColors.gold400 : FatFishColors.line,
          width: chosen ? 2 : 1,
        ),
      ),
      child: AnimatedSwitcher(
        duration: motionDuration(context, FatFishMotion.base),
        switchInCurve: FatFishMotion.curve,
        // Old and new content share the top left corner while they cross-fade.
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: Row(
          key: ValueKey(player?.id),
          children: [
            if (player == null)
              const PixelIcon(
                PixelIcons.player,
                size: 48,
                color: FatFishColors.fog400,
              )
            else
              PlayerAvatar(player, size: 48),
            const SizedBox(width: FatFishSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (player == null) ...[
                    Text('Sin elegir', style: textTheme.headlineSmall),
                    Text(
                      'Búscate para ver tu expediente.',
                      style: textTheme.bodySmall,
                    ),
                  ] else ...[
                    Text(player.alias, style: textTheme.headlineSmall),
                    Text('#${player.id}', style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (player != null)
              IconButton(
                tooltip: 'Quitar jugador',
                onPressed: onClear,
                icon: const PixelIcon(
                  PixelIcons.close,
                  size: 12,
                  color: FatFishColors.fog400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
