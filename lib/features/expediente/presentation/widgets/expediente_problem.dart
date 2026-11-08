import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/retry_button.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/cubit/expediente_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The saved player does not exist in the API: offers to pick another one.
class PlayerNotFoundNotice extends StatelessWidget {
  const PlayerNotFoundNotice(this.player, {super.key});

  final PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    return Notice(
      icon: PixelIcons.player,
      text:
          'No encontramos a ${player.alias} (#${player.id}). Elige otro jugador.',
      action: const GoToJugadorButton('Elegir otro jugador'),
    );
  }
}

/// The first load failed: the message of the error and a button to try again.
class LoadFailedNotice extends StatelessWidget {
  const LoadFailedNotice({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Notice(
      icon: PixelIcons.offline,
      text: message,
      color: FatFishColors.cream100,
      action: RetryButton(onRetry: onRetry, outlined: true),
    );
  }
}

/// Shows once, over the data, a refresh or "Ver más" that failed. The dossier and the
/// history share the Cubit, so only the screen on top reports it.
class ExpedienteFailureListener extends StatelessWidget {
  const ExpedienteFailureListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpedienteCubit, ExpedienteState>(
      listenWhen: (previous, current) =>
          current is ExpedienteLoaded &&
          current.failure != null &&
          (previous is! ExpedienteLoaded ||
              previous.failure != current.failure),
      listener: (context, state) {
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        final message = (state as ExpedienteLoaded).failure!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: child,
    );
  }
}

/// Main button that opens the search to pick a player.
class GoToJugadorButton extends StatelessWidget {
  const GoToJugadorButton(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(FatFishRadius.card),
        boxShadow: FatFishShadows.hard,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
        onPressed: () => GoRouter.maybeOf(context)?.push(AppRoutes.jugador),
        child: Text(label),
      ),
    );
  }
}
