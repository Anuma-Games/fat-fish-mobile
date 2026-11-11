import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/search_players.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'player_search_state.dart';

class PlayerSearchCubit extends Cubit<PlayerSearchState> {
  PlayerSearchCubit({
    required this._searchPlayers,
    this.debounce = const Duration(milliseconds: 350),
  }) : super(const PlayerSearchInitial());

  final SearchPlayers _searchPlayers;

  /// Pause after the last keystroke before asking the API.
  final Duration debounce;

  /// Latest text sent to the API; older answers that arrive late are dropped.
  String? _lastQuery;

  /// Pending search while the player is still typing.
  Timer? _debounceTimer;

  /// Called on every keystroke. Waits until the player stops typing before asking the API.
  void queryChanged(String query) {
    final text = query.trim();
    // Too short to be useful: back to the card at once, without waiting.
    // One letter matches almost anyone; one digit is still a valid player number.
    if (text.length < 2 && !_digitsOnly.hasMatch(text)) {
      // Also drops a pending or running search for longer text.
      _debounceTimer?.cancel();
      _lastQuery = '';
      if (state is! PlayerSearchInitial) emit(const PlayerSearchInitial());
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => search(text));
  }

  static final _digitsOnly = RegExp(r'^\d+$');

  /// Searches right away, for example when the player presses enter.
  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    final text = query.trim();
    _lastQuery = text;
    if (text.isEmpty) {
      emit(const PlayerSearchInitial());
      return;
    }

    emit(PlayerSearchLoading(_visiblePlayers));
    try {
      final players = await _searchPlayers(text);
      if (text != _lastQuery || isClosed) return;
      emit(
        players.isEmpty ? PlayerSearchEmpty(text) : PlayerSearchLoaded(players),
      );
    } on ApiException catch (e) {
      if (text != _lastQuery || isClosed) return;
      emit(PlayerSearchFailure(e.message));
    }
  }

  /// Back to the initial state, for example after choosing a player.
  void clear() => search('');

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Results on screen, kept while the next search loads so the list does not blink.
  List<PlayerSummary> get _visiblePlayers => switch (state) {
    PlayerSearchLoaded(:final players) => players,
    PlayerSearchLoading(:final players) => players,
    _ => const [],
  };
}
