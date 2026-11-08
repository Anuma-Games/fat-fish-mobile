import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/cubit/expediente_cubit.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/dossier_sheet.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/expediente_problem.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/match_row.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// What the casino knows about the saved player. `ExpedienteScope`, in the router,
/// provides the Cubit this page shares with the history.
class ExpedientePage extends StatelessWidget {
  const ExpedientePage({super.key});

  /// Matches shown here; the rest are in the history.
  static const recentMatches = 3;

  @override
  Widget build(BuildContext context) {
    final myPlayer = context.watch<MyPlayerCubit>().state;

    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'Expediente'),
      body: switch (myPlayer) {
        // Reading the device takes a moment; nothing flashes meanwhile.
        MyPlayerLoading() => const SizedBox.shrink(),
        // The router sends this case to the welcome screen; this stays for a
        // page shown without the router.
        MyPlayerNone() => Builder(
          builder: (context) => ListView(
            padding: FatFishAppBar.pageInsets(context),
            children: const [
              Notice(
                icon: PixelIcons.player,
                text: 'Elige tu jugador para ver lo que el casino sabe de ti.',
                action: GoToJugadorButton('Buscar mi jugador'),
              ),
            ],
          ),
        ),
        MyPlayerChosen(:final player) => ExpedienteFailureListener(
          child: _ExpedienteView(player),
        ),
      },
    );
  }
}

class _ExpedienteView extends StatelessWidget {
  const _ExpedienteView(this.player);

  /// The saved player: enough for the sheet while the profile loads.
  final PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpedienteCubit>();
    final insets = FatFishAppBar.pageInsets(context);

    return BlocBuilder<ExpedienteCubit, ExpedienteState>(
      builder: (context, state) => switch (state) {
        ExpedienteLoading() => ListView(
          padding: insets,
          children: [_LoadingDossier(player)],
        ),
        ExpedienteLoaded() => RefreshIndicator(
          // Below the bar, where the content starts.
          edgeOffset: insets.top - 20,
          onRefresh: cubit.refresh,
          child: _Dossier(state),
        ),
        ExpedienteNotFound() => ListView(
          padding: insets,
          children: [PlayerNotFoundNotice(player)],
        ),
        ExpedienteFailure(:final message) => ListView(
          padding: insets,
          children: [LoadFailedNotice(message: message, onRetry: cubit.load)],
        ),
      },
    );
  }
}

class _Dossier extends StatelessWidget {
  const _Dossier(this.state);

  final ExpedienteLoaded state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stats = state.profile.stats;
    final cut = houseCut(invested: stats.moneyInvested, lost: stats.moneyLost);
    final recent = state.matches.take(ExpedientePage.recentMatches).toList();
    void openHistory() => context.go(AppRoutes.historial);
    final insets = FatFishAppBar.pageInsets(context);

    return ListView(
      // "Cambiar" is taller than the tab of the sheet; its extra height eats into the
      // top margin, so the sheet starts where the design puts it.
      padding: insets.copyWith(
        top: insets.top - DossierSheet.changeButtonOverhang,
      ),
      // Pull to refresh works even when the dossier is shorter than the screen.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        DossierSheet(
          profile: state.profile,
          now: DateTime.now(),
          onChangePlayer: () => context.push(AppRoutes.jugador),
        ),
        if (cut != null) ...[
          const SizedBox(height: 20),
          HouseReceipt(cut: cut),
        ],
        const SizedBox(height: FatFishSpacing.s6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Historial',
                style: textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
            ),
            if (state.totalMatches > 0)
              TextButton(
                onPressed: openHistory,
                style: TextButton.styleFrom(
                  foregroundColor: FatFishColors.gold400,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: FatFishSpacing.s1,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: FatFishFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  state.totalMatches == 1
                      ? 'Ver la partida'
                      : 'Ver las ${formatNumber(state.totalMatches)} partidas',
                ),
              ),
          ],
        ),
        const SizedBox(height: FatFishSpacing.s2),
        if (recent.isEmpty)
          Text(
            'Este jugador todavía no tiene partidas.',
            style: textTheme.bodyMedium?.copyWith(color: FatFishColors.fog400),
          )
        else
          RowsPanel(
            children: [
              for (final (index, match) in recent.indexed)
                Appear(
                  key: ValueKey(match.id),
                  delay: FatFishMotion.stagger * index,
                  child: MatchRow(match, onTap: openHistory),
                ),
            ],
          ),
      ],
    );
  }
}

/// While the profile loads: the saved alias on a sheet, and blocks where the data goes.
class _LoadingDossier extends StatelessWidget {
  const _LoadingDossier(this.player);

  final PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    Widget block({double? width, required double height, double opacity = 1}) =>
        Opacity(
          opacity: opacity,
          child: Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              color: FatFishColors.bg700,
              border: Border.fromBorderSide(
                BorderSide(color: FatFishColors.line),
              ),
              borderRadius: BorderRadius.all(FatFishRadius.card),
            ),
          ),
        );

    Widget bar(double widthFactor) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 12,
        decoration: const BoxDecoration(
          color: FatFishColors.line,
          borderRadius: BorderRadius.all(FatFishRadius.field),
        ),
      ),
    );

    return Semantics(
      label: 'Cargando el expediente de ${player.alias}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(FatFishSpacing.s4),
            decoration: const BoxDecoration(
              color: FatFishColors.bg700,
              border: Border.fromBorderSide(
                BorderSide(color: FatFishColors.gold600, width: 2),
              ),
              borderRadius: BorderRadius.all(FatFishRadius.card),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: FatFishColors.bg800,
                    borderRadius: BorderRadius.all(FatFishRadius.field),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.alias,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 38, height: 0.95),
                      ),
                      const SizedBox(height: FatFishSpacing.s2),
                      bar(0.7),
                      const SizedBox(height: FatFishSpacing.s2),
                      bar(0.5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: FatFishSpacing.s2),
            Row(
              children: [
                Expanded(child: block(height: 96)),
                const SizedBox(width: FatFishSpacing.s2),
                Expanded(child: block(height: 96)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          block(height: 90),
          const SizedBox(height: 14),
          block(height: 90, opacity: 0.6),
        ],
      ),
    );
  }
}
