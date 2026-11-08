import 'package:equatable/equatable.dart';

/// Public data of a player plus the six statistics of the dossier.
class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.id,
    required this.alias,
    required this.createdAt,
    this.lastActivity,
    required this.stats,
    required this.generatedAt,
    this.savedAt,
  });

  final String id;
  final String alias;
  final DateTime createdAt;

  /// Null when the player has an account but has not sent any match yet.
  final DateTime? lastActivity;
  final ProfileStats stats;

  /// When the API built the answer; the screen shows it as the date of the data.
  final DateTime generatedAt;

  /// When this copy was saved on the device, if it was read there because there is no
  /// connection. Null for a fresh answer.
  final DateTime? savedAt;

  @override
  List<Object?> get props => [
    id,
    alias,
    createdAt,
    lastActivity,
    stats,
    generatedAt,
    savedAt,
  ];
}

/// The six statistics of the dossier. The API updates them with every match.
/// Money is fictitious and has no cents.
class ProfileStats extends Equatable {
  const ProfileStats({
    required this.totalMatches,
    required this.matchesWon,
    required this.moneyInvested,
    required this.moneyLost,
    required this.longestLosingStreak,
    required this.secondsPlayed,
  });

  final int totalMatches;
  final int matchesWon;
  final int moneyInvested;
  final int moneyLost;
  final int longestLosingStreak;
  final int secondsPlayed;

  @override
  List<Object?> get props => [
    totalMatches,
    matchesWon,
    moneyInvested,
    moneyLost,
    longestLosingStreak,
    secondsPlayed,
  ];
}
