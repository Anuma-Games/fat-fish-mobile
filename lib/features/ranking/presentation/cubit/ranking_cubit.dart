import 'package:equatable/equatable.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/usecases/get_ranking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ranking_state.dart';

/// The ranking, one page at a time, and the place of [playerId] when there is one.
/// The page builds a new one when the saved player changes.
class RankingCubit extends Cubit<RankingState> {
  RankingCubit({required this._getRanking, this.playerId})
    : super(const RankingLoading());

  final GetRanking _getRanking;
  final String? playerId;

  /// Grows with every request; an answer whose number is not the latest is dropped,
  /// so tapping two pages quickly never shows the first one last.
  int _request = 0;

  /// First load, and "Reintentar" after an error.
  Future<void> load() async {
    emit(const RankingLoading());
    await _show(0);
  }

  /// Pull to refresh: the current page stays on screen while it reloads.
  /// While a page is loading, the refresh asks for that page, not the one on screen.
  Future<void> refresh() async {
    final current = state;
    if (current is! RankingLoaded) return load();
    // Clears the last error first: a second failure in a row is a new state, so the
    // screen reports it again.
    emit(current.copyWith(loadingPage: current.loadingPage));
    await _show(current.loadingPage ?? current.ranking.page);
  }

  /// A page number of the bar, from 0. The current page stays until the new one arrives.
  Future<void> goToPage(int page) async {
    final current = state;
    if (current is! RankingLoaded) return;
    if (page < 0 || page >= current.ranking.totalPages) return;
    if (page == current.ranking.page && current.loadingPage == null) return;
    emit(current.copyWith(loadingPage: page));
    await _show(page);
  }

  Future<void> _show(int page) async {
    final request = ++_request;
    try {
      final ranking = await _getRanking(page: page, playerId: playerId);
      if (request != _request || isClosed) return;
      emit(RankingLoaded(ranking: ranking));
    } on ApiException catch (e) {
      if (request != _request || isClosed) return;
      // A failed page or refresh keeps the data on screen and only reports the error.
      emit(switch (state) {
        final RankingLoaded loaded => loaded.copyWith(failure: e.message),
        _ => RankingFailure(e.message),
      });
    }
  }
}
