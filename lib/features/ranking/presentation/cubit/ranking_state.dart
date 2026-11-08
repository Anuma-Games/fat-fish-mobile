part of 'ranking_cubit.dart';

sealed class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

final class RankingLoading extends RankingState {
  const RankingLoading();
}

final class RankingLoaded extends RankingState {
  const RankingLoaded({required this.ranking, this.loadingPage, this.failure});

  final Ranking ranking;

  /// The page asked for while [ranking] stays on screen.
  final int? loadingPage;

  /// Message of a page or refresh that failed, shown once over the data.
  final String? failure;

  /// [loadingPage] and [failure] are cleared unless given: each change starts clean.
  RankingLoaded copyWith({int? loadingPage, String? failure}) => RankingLoaded(
    ranking: ranking,
    loadingPage: loadingPage,
    failure: failure,
  );

  @override
  List<Object?> get props => [ranking, loadingPage, failure];
}

/// The first load failed. [message] comes from `ApiException` and is shown as is.
final class RankingFailure extends RankingState {
  const RankingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
