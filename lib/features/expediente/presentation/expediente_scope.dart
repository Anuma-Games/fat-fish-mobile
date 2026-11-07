import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_matches.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_profile.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/cubit/expediente_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Gives the dossier and the history one [ExpedienteCubit] for the saved player, so the
/// history continues the pages the dossier already loaded. Without a player it adds none.
class ExpedienteScope extends StatelessWidget {
  const ExpedienteScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final myPlayer = context.watch<MyPlayerCubit>().state;
    if (myPlayer is! MyPlayerChosen) return child;

    // The key gives each player a new Cubit, so the old dossier never shows
    // under the new name.
    return BlocProvider(
      key: ValueKey(myPlayer.player.id),
      create: (context) {
        final expediente = context.read<ExpedienteRepository>();
        return ExpedienteCubit(
          playerId: myPlayer.player.id,
          getProfile: GetProfile(expediente),
          getMatches: GetMatches(expediente),
        )..load();
      },
      child: child,
    );
  }
}
