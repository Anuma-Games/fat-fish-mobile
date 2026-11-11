part of 'player_search_cubit.dart';

sealed class PlayerSearchState extends Equatable {
  const PlayerSearchState();

  @override
  List<Object?> get props => [];
}

/// Nothing searched yet.
final class PlayerSearchInitial extends PlayerSearchState {
  const PlayerSearchInitial();
}

/// [players] are the previous results, still shown while the new ones load.
final class PlayerSearchLoading extends PlayerSearchState {
  const PlayerSearchLoading([this.players = const []]);

  final List<PlayerSummary> players;

  @override
  List<Object?> get props => [players];
}

final class PlayerSearchLoaded extends PlayerSearchState {
  const PlayerSearchLoaded(this.players);

  final List<PlayerSummary> players;

  @override
  List<Object?> get props => [players];
}

/// The API answered, but no player matches [query].
final class PlayerSearchEmpty extends PlayerSearchState {
  const PlayerSearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// [message] comes from `ApiException` and is shown as is.
final class PlayerSearchFailure extends PlayerSearchState {
  const PlayerSearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
