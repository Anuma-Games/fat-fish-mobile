import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/offline_notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/cubit/expediente_cubit.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/expediente_problem.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/match_row.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every match of the saved player, newest first, a page at a time. It continues the
/// pages the dossier already loaded, through the Cubit of `ExpedienteScope`.
class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myPlayer = context.watch<MyPlayerCubit>().state;

    return Scaffold(
      // Plain background, so the list leads.
      backgroundColor: FatFishColors.bg900,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'Historial'),
      body: switch (myPlayer) {
        MyPlayerChosen(:final player) => ExpedienteFailureListener(
          child: _HistorialView(player),
        ),
        // The player was removed while this screen was open.
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _HistorialView extends StatelessWidget {
  const _HistorialView(this.player);

  final PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpedienteCubit>();
    final insets = FatFishAppBar.pageInsets(context);

    return BlocBuilder<ExpedienteCubit, ExpedienteState>(
      builder: (context, state) => switch (state) {
        ExpedienteLoading() => const Center(child: CircularProgressIndicator()),
        ExpedienteLoaded() => RefreshIndicator(
          edgeOffset: insets.top - 20,
          onRefresh: cubit.refresh,
          child: _History(player: player, state: state),
        ),
        ExpedienteNotFound() => ListView(
          padding: insets,
          children: [PlayerNotFoundNotice(player)],
        ),
        ExpedienteFailure(:final message) => ListView(
          padding: insets,
          children: [LoadFailedNotice(message: message, onRetry: cubit.retry)],
        ),
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.player, required this.state});

  final PlayerSummary player;
  final ExpedienteLoaded state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matches = state.matches;
    final savedAt = state.profile.savedAt;

    return ListView(
      padding: FatFishAppBar.pageInsets(context),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (savedAt != null) ...[
          OfflineNotice(
            savedOn: formatSavedAt(savedAt),
            onRetry: context.read<ExpedienteCubit>().refresh,
          ),
          const SizedBox(height: FatFishSpacing.s4),
        ],
        MergeSemantics(
          child: Row(
            children: [
              PlayerAvatar(player, size: 24),
              const SizedBox(width: FatFishSpacing.s2),
              Text(
                player.alias,
                style: const TextStyle(
                  fontFamily: FatFishFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FatFishColors.cream100,
                ),
              ),
              const SizedBox(width: FatFishSpacing.s2),
              Text('#${player.id}', style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Cada partida, anotada',
          style: textTheme.headlineLarge?.copyWith(height: 1),
        ),
        const SizedBox(height: 10),
        Text(
          'De la más reciente a la más antigua.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        if (matches.isEmpty)
          Text(
            'Este jugador todavía no tiene partidas.',
            style: textTheme.bodyMedium?.copyWith(color: FatFishColors.fog400),
          )
        else ...[
          RowsPanel(
            children: [
              for (final (index, match) in matches.indexed)
                // Each page enters one row after another; rows already on screen
                // keep their key and stay still.
                Appear(
                  key: ValueKey(match.id),
                  delay: FatFishMotion.stagger * (index % matchPageSize),
                  child: MatchRow(match, showInvested: true),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Offline only the pages already saved are here; the rest wait for a
          // connection.
          if (state.hasMore && savedAt != null)
            Padding(
              padding: const EdgeInsets.all(FatFishSpacing.s2),
              child: Text(
                'El historial guardado tiene ${formatNumber(matches.length)} '
                'de ${formatNumber(state.totalMatches)} partidas. '
                '“Ver más” vuelve cuando haya red.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            )
          else if (state.hasMore)
            _MoreButton(loading: state.loadingMore)
          else
            Padding(
              padding: const EdgeInsets.all(FatFishSpacing.s2),
              child: Text(
                '“Esa fue tu primera partida. Desde ahí te vengo siguiendo.”',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      // Disabled while loading, so a second tap does not ask for the same page.
      onPressed: loading ? null : context.read<ExpedienteCubit>().loadMore,
      icon: loading
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const PixelIcon(
              PixelIcons.arrowDown,
              color: FatFishColors.cream100,
            ),
      label: const Text('Ver más partidas'),
    );
  }
}
