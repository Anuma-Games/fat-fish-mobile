import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:flutter/material.dart';

/// Translucent box for a list of player rows. Its edges line up with the search
/// field and the card; the rows inside keep the card's 16 px inset.
class PlayerListPanel extends StatelessWidget {
  const PlayerListPanel({super.key, required this.children});

  final List<Widget> children;

  /// Divider indent: row inset + avatar + gap, so it starts under the text.
  static const _dividerIndent =
      FatFishSpacing.s4 + PlayerAvatar.defaultSize + FatFishSpacing.s3;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Clips the rows' ink and the swipe background to the rounded corners.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // Translucent so the casino pattern shows through, like a felt overlay.
        color: FatFishColors.bg700.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.all(FatFishRadius.card),
        border: Border.all(color: FatFishColors.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: _dividerIndent,
                  color: FatFishColors.line,
                ),
              child,
            ],
          ],
        ),
      ),
    );
  }
}
