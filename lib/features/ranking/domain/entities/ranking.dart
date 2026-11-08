import 'package:equatable/equatable.dart';

/// One place of the world ranking: the best score of a player in a match they won.
class RankingEntry extends Equatable {
  const RankingEntry({
    required this.position,
    required this.playerId,
    required this.alias,
    required this.score,
    required this.achievedAt,
  });

  final int position;
  final String playerId;
  final String alias;
  final int score;

  /// When the winning match ended; on a tie, the earlier one goes first.
  final DateTime achievedAt;

  @override
  List<Object?> get props => [position, playerId, alias, score, achievedAt];
}

/// One page of the ranking, plus the place of the saved player.
class Ranking extends Equatable {
  const Ranking({
    required this.entries,
    required this.page,
    required this.totalPages,
    this.myPosition,
  });

  final List<RankingEntry> entries;

  /// Index of this page, starting at 0.
  final int page;
  final int totalPages;

  /// Real place of the saved player, even beyond the top 50. Null without a player
  /// or when the player has not won a match yet.
  final RankingEntry? myPosition;

  @override
  List<Object?> get props => [entries, page, totalPages, myPosition];
}
