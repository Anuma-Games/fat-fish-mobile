import 'package:equatable/equatable.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
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
  }) : super(const ExpedienteLoading());

  final String playerId;
  final GetProfile _getProfile;
  final GetMatches _getMatches;

  /// Grows with every request; an answer whose number is not the latest is dropped,
  /// so a refresh and a "Ver más" that cross never mix their pages.
  int _request = 0;

  /// First load, and "Reintentar" after an error.
  Future<void> load() async {
    emit(const ExpedienteLoading());
    await _loadFirstPage();
  }

  /// Pull to refresh: the dossier stays on screen while it reloads.
  Future<void> refresh() =>
      state is ExpedienteLoaded ? _loadFirstPage() : load();

  Future<void> _loadFirstPage() async {
    final request = ++_request;
    try {
      // Both requests travel at once.
      final [
        profile as PlayerProfile,
        page as MatchPage,
      ] = await Future.wait<Object>([
        _getProfile(playerId),
        _getMatches(playerId, page: 0),
      ]);
      if (request != _request || isClosed) return;
      emit(
        ExpedienteLoaded(
          profile: profile,
          matches: page.matches,
          page: page.page,
          totalMatches: page.totalMatches,
          hasMore: !page.isLast,
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
    if (current.loadingMore) return;

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
