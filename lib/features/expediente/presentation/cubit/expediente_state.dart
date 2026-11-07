part of 'expediente_cubit.dart';

sealed class ExpedienteState extends Equatable {
  const ExpedienteState();

  @override
  List<Object?> get props => [];
}

final class ExpedienteLoading extends ExpedienteState {
  const ExpedienteLoading();
}

final class ExpedienteLoaded extends ExpedienteState {
  const ExpedienteLoaded({
    required this.profile,
    required this.matches,
    required this.page,
    required this.totalMatches,
    required this.hasMore,
    this.loadingMore = false,
    this.failure,
  });

  final PlayerProfile profile;

  /// Every page loaded so far, newest match first.
  final List<PlayedMatch> matches;

  /// Index of the last page loaded.
  final int page;
  final int totalMatches;
  final bool hasMore;
  final bool loadingMore;

  /// Message of a refresh or "Ver más" that failed, shown once over the data.
  final String? failure;

  /// [failure] is cleared unless given: each change starts without an error.
  ExpedienteLoaded copyWith({
    List<PlayedMatch>? matches,
    int? page,
    int? totalMatches,
    bool? hasMore,
    bool loadingMore = false,
    String? failure,
  }) => ExpedienteLoaded(
    profile: profile,
    matches: matches ?? this.matches,
    page: page ?? this.page,
    totalMatches: totalMatches ?? this.totalMatches,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    profile,
    matches,
    page,
    totalMatches,
    hasMore,
    loadingMore,
    failure,
  ];
}

/// The API does not know the player saved on this device.
final class ExpedienteNotFound extends ExpedienteState {
  const ExpedienteNotFound();
}

/// The first load failed. [message] comes from `ApiException` and is shown as is.
final class ExpedienteFailure extends ExpedienteState {
  const ExpedienteFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
