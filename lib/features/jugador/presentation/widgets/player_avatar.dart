import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:flutter/material.dart';

/// Initials on a color picked from the player number. Players have no photo, and the
/// color tells apart players with the same alias.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar(this.player, {super.key, this.size = defaultSize});

  static const defaultSize = 40.0;

  final PlayerSummary player;
  final double size;

  static const _colors = [
    FatFishColors.felt700,
    FatFishColors.red,
    FatFishColors.gold600,
    FatFishColors.line,
  ];

  /// The color of a player, the same on every screen: search, dossier and ranking.
  static Color colorFor(String playerId) {
    final seed = int.tryParse(playerId) ?? playerId.hashCode;
    return _colors[seed.abs() % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Decoration only: the alias next to it already says who it is.
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorFor(player.id),
          borderRadius: const BorderRadius.all(FatFishRadius.card),
        ),
        child: Text(
          initialsOf(player.alias),
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontSize: size / 2),
        ),
      ),
    );
  }
}

/// "Don Ramon" → "DR"; one word → its first two letters ("rk_01" → "RK").
String initialsOf(String alias) {
  final words = alias.trim().split(RegExp(r'\s+'));
  if (words.first.isEmpty) return '?';
  final initials = words.length == 1
      ? words.first.characters.take(2).toString()
      : words[0].characters.first + words[1].characters.first;
  return initials.toUpperCase();
}
