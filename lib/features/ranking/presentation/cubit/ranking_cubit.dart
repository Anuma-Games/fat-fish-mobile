import 'package:equatable/equatable.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/usecases/get_ranking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ranking_state.dart';

/// The ranking, one page at a time, and the place of [playerId] when there is one.
/// The page builds a new one when the saved player changes.
class RankingCubit extends Cubit<RankingState> {
  RankingCubit({
    required this._getRanking,
    this.playerId,
    this.minimumWait = FatFishMotion.retryMinimum,
  }) : super(const RankingLoading());

  final GetRanking _getRanking;
  final String? playerId;

  /// Shortest refresh or retry, so the spinner the player asked for is seen.
  final Duration minimumWait;

  /// Grows with every request; an answer whose number is not the latest is dropped,
  /// so tapping two pages quickly never shows the first one last.
  int _request = 0;

  /// First load, and "Reintentar" after an error.
  Future<void> load() async {
    emit(const RankingLoading());
    await _show(0);
  }

  /// "Reintentar" after a failed first load: the error stays on screen, with its button
  /// spinning, until the answer arrives, instead of flashing the spinner of the page.
  Future<void> retry() => _show(0, slow: true);

  /// Pull to refresh: the current page stays on screen while it reloads.
  /// While a page is loading, the refresh asks for that page, not the one on screen.
  Future<void> refresh() async {
    final current = state;
    if (current is! RankingLoaded) return load();
    // Clears the last error first: a second failure in a row is a new state, so the
    // screen reports it again.
    emit(current.copyWith(loadingPage: current.loadingPage));
    await _show(
      current.loadingPage ?? current.ranking.page,
      reportOffline: true,
      slow: true,
    );
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

  /// With [reportOffline], an answer that only came from the device says so: the
  /// player asked again and is still without connection. With [slow], it lasts at
  /// least [minimumWait].
  Future<void> _show(
    int page, {
    bool reportOffline = false,
    bool slow = false,
  }) async {
    final request = ++_request;
    try {
      final ranking = await atLeast(
        _getRanking(page: page, playerId: playerId),
        slow ? minimumWait : Duration.zero,
      );
      if (request != _request || isClosed) return;
      emit(
        RankingLoaded(
          ranking: ranking,
          failure: reportOffline && ranking.savedAt != null
              ? const NetworkException().message
              : null,
        ),
      );
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
