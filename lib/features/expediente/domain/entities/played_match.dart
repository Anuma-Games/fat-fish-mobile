import 'package:equatable/equatable.dart';

enum MatchResult { victory, defeat, abandoned }

/// One match of the history. Named PlayedMatch because `Match` is a dart:core class.
class PlayedMatch extends Equatable {
  const PlayedMatch({
    required this.id,
    required this.result,
    required this.roundReached,
    required this.score,
    required this.moneyInvested,
    required this.moneyWon,
    required this.moneyLost,
    required this.durationSeconds,
    required this.playedAt,
  });

  final String id;
  final MatchResult result;

  /// Rounds have no limit: a victory at round 9 can go on.
  final int roundReached;
  final int score;
  final int moneyInvested;
  final int moneyWon;
  final int moneyLost;
  final int durationSeconds;

  /// When the match ended.
  final DateTime playedAt;

  @override
  List<Object?> get props => [
    id,
    result,
    roundReached,
    score,
    moneyInvested,
    moneyWon,
    moneyLost,
    durationSeconds,
    playedAt,
  ];
}

/// One page of the history, newest match first.
class MatchPage extends Equatable {
  const MatchPage({
    required this.matches,
    required this.page,
    required this.totalMatches,
    required this.isLast,
    this.savedAt,
  });

  final List<PlayedMatch> matches;

  /// Index of this page, starting at 0.
  final int page;
  final int totalMatches;
  final bool isLast;

  /// When this copy was saved on the device, if it was read there because there is no
  /// connection. Null for a fresh answer.
  final DateTime? savedAt;

  @override
  List<Object?> get props => [matches, page, totalMatches, isLast, savedAt];
}
