import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';

part 'my_player_state.dart';

/// The player this device follows. Lives above the router, so every tab reads the same one.
class MyPlayerCubit extends Cubit<MyPlayerState> {
  MyPlayerCubit({
    required this._getMyPlayer,
    required this._saveMyPlayer,
    required this._clearMyPlayer,
  }) : super(const MyPlayerLoading());

  final GetMyPlayer _getMyPlayer;
  final SaveMyPlayer _saveMyPlayer;
  final ClearMyPlayer _clearMyPlayer;

  Future<void> load() async {
    final player = await _getMyPlayer();
    emit(player == null ? const MyPlayerNone() : MyPlayerChosen(player));
  }

  Future<void> choose(PlayerSummary player) async {
    await _saveMyPlayer(player);
    emit(MyPlayerChosen(player));
  }

  Future<void> clear() async {
    await _clearMyPlayer();
    emit(const MyPlayerNone());
  }
}
