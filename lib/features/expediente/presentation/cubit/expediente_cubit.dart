import 'package:equatable/equatable.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_matches.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expediente_state.dart';

/// Dossier and history of one player. The page builds a new one when the player changes.
class ExpedienteCubit extends Cubit<ExpedienteState> {
  ExpedienteCubit({
    required this.playerId,
    required this._getProfile,
    required this._getMatches,
    this.minimumWait = FatFishMotion.retryMinimum,
  }) : super(const ExpedienteLoading());

  final String playerId;
  final GetProfile _getProfile;
  final GetMatches _getMatches;

  /// Shortest refresh or retry, so the spinner the player asked for is seen.
  final Duration minimumWait;

  /// Grows with every request; an answer whose number is not the latest is dropped,
  /// so a refresh and a "Ver más" that cross never mix their pages.
  int _request = 0;

  /// First load, and "Reintentar" after an error.
  Future<void> load() async {
    emit(const ExpedienteLoading());
    await _loadFirstPage();
  }

  /// "Reintentar" after a failed first load: the error stays on screen, with its button
  /// spinning, until the answer arrives, instead of flashing the loading blocks.
  Future<void> retry() => _loadFirstPage(slow: true);

  /// Refreshes still on their way; "Ver más" waits for them.
  int _refreshing = 0;

  /// Pull to refresh: the dossier stays on screen while it reloads.
  Future<void> refresh() async {
    final current = state;
    if (current is! ExpedienteLoaded) return load();
    // Clears the last error first: a second failure in a row is a new state, so the
    // screen reports it again.
    emit(current.copyWith());
    _refreshing++;
    try {
      await _loadFirstPage(reportOffline: true, slow: true);
    } finally {
      _refreshing--;
    }
  }

  /// With [reportOffline], an answer that only came from the device says so: the
  /// player asked again and is still without connection. With [slow], it lasts at
  /// least [minimumWait].
  Future<void> _loadFirstPage({
    bool reportOffline = false,
    bool slow = false,
  }) async {
    final request = ++_request;
    try {
      // Both requests travel at once.
      final [profile as PlayerProfile, page as MatchPage] = await atLeast(
        Future.wait<Object>([
          _getProfile(playerId),
          _getMatches(playerId, page: 0),
        ]),
        slow ? minimumWait : Duration.zero,
      );
      if (request != _request || isClosed) return;
      emit(
        ExpedienteLoaded(
          profile: profile,
          matches: page.matches,
          page: page.page,
          totalMatches: page.totalMatches,
          hasMore: !page.isLast,
          failure: reportOffline && profile.savedAt != null
              ? const NetworkException().message
              : null,
        ),
      );
    } on NotFoundException {
      if (request != _request || isClosed) return;
      emit(const ExpedienteNotFound());
    } on ApiException catch (e) {
      if (request != _request || isClosed) return;
      // A failed refresh keeps the data on screen and only reports the error.
      emit(switch (state) {
        final ExpedienteLoaded loaded => loaded.copyWith(failure: e.message),
        _ => ExpedienteFailure(e.message),
      });
    }
  }

  /// "Ver más partidas": appends the next page of the history.
  Future<void> loadMore() async {
    final current = state;
    if (current is! ExpedienteLoaded || !current.hasMore) return;
    // A refresh brings a new first page; the next page waits for it, or it would
    // drop the refresh and land on the old list.
    if (current.loadingMore || _refreshing > 0) return;

    final request = ++_request;
    emit(current.copyWith(loadingMore: true));
    try {
      final page = await _getMatches(playerId, page: current.page + 1);
      if (request != _request || isClosed) return;
      // A match sent between two pages pushes the older ones down one place,
      // so the next page can repeat the last match already on screen.
      final shown = {for (final match in current.matches) match.id};
      emit(
        current.copyWith(
          matches: [
            ...current.matches,
            ...page.matches.where((match) => !shown.contains(match.id)),
          ],
          page: page.page,
          totalMatches: page.totalMatches,
          hasMore: !page.isLast,
        ),
      );
    } on ApiException catch (e) {
      if (request != _request || isClosed) return;
      emit(current.copyWith(failure: e.message));
    }
  }
}
