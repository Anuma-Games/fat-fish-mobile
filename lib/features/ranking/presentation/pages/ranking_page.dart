import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/offline_notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/paper.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/formatters/expediente_text.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/retry_button.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/match_row.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:fat_fish_mobile/features/ranking/domain/usecases/get_ranking.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/cubit/ranking_cubit.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/my_place_card.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/page_bar.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/podium.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/ranking_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// World ranking: the best winning score of each player, up to place 50, with the
/// place of the saved player.
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  /// Places on the podium; the list of the first page starts after them.
  static const podiumSize = 3;

  @override
  Widget build(BuildContext context) {
    final myPlayer = context.watch<MyPlayerCubit>().state;
    final player = switch (myPlayer) {
      MyPlayerChosen(:final player) => player,
      _ => null,
    };

    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'Ranking'),
      body: switch (myPlayer) {
        // Reading the device takes a moment; the ranking waits to ask with the player.
        MyPlayerLoading() => const SizedBox.shrink(),
        _ => BlocProvider(
          // A new player asks again for their place.
          key: ValueKey(player?.id),
          create: (context) => RankingCubit(
            getRanking: GetRanking(context.read<RankingRepository>()),
            playerId: player?.id,
          )..load(),
          child: _RankingView(player),
        ),
      },
    );
  }
}

class _RankingView extends StatelessWidget {
  const _RankingView(this.player);

  final PlayerSummary? player;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RankingCubit>();
    final insets = FatFishAppBar.pageInsets(context);

    return BlocConsumer<RankingCubit, RankingState>(
      listenWhen: (previous, current) =>
          current is RankingLoaded &&
          current.failure != null &&
          (previous is! RankingLoaded || previous.failure != current.failure),
      listener: (context, state) {
        final message = (state as RankingLoaded).failure!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) => switch (state) {
        RankingLoading() => const Center(child: CircularProgressIndicator()),
        RankingLoaded() => RefreshIndicator(
          edgeOffset: insets.top - 20,
          onRefresh: cubit.refresh,
          child: _Ranking(player: player, state: state),
        ),
        RankingFailure(:final message) => ListView(
          padding: insets,
          children: [
            Notice(
              icon: PixelIcons.offline,
              text: message,
              color: FatFishColors.cream100,
              action: RetryButton(onRetry: cubit.retry, outlined: true),
            ),
          ],
        ),
      },
    );
  }
}

class _Ranking extends StatelessWidget {
  const _Ranking({required this.player, required this.state});

  final PlayerSummary? player;
  final RankingLoaded state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ranking = state.ranking;
    final player = this.player;
    final firstPage = ranking.page == 0;
    final entries = ranking.entries;
    final podium = firstPage
        ? entries.take(RankingPage.podiumSize).toList()
        : const <Never>[];
    final rows = entries.skip(podium.length).toList();

    return ListView(
      // A new list per page, so each page opens at the top.
      key: ValueKey(ranking.page),
      padding: FatFishAppBar.pageInsets(context),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (ranking.savedAt case final savedAt?) ...[
          OfflineNotice(
            savedOn: formatSavedAt(savedAt),
            onRetry: context.read<RankingCubit>().refresh,
          ),
          const SizedBox(height: FatFishSpacing.s4),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'Las mejores partidas',
                style: textTheme.headlineLarge?.copyWith(height: 1),
              ),
            ),
            IconButton(
              tooltip: 'Cómo funciona el ranking',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const _RankingHelpNote(),
              ),
            ),
          ],
        ),
        if (firstPage) ...[
          const SizedBox(height: 6),
          Text(
            'Cuenta el mayor puntaje en una partida ganada. '
            'En empate, gana quien lo consiguió primero.',
            style: textTheme.bodySmall,
          ),
          if (player != null) ...[
            const SizedBox(height: FatFishSpacing.s4),
            MyPlaceCard(player: player, place: ranking.myPosition),
          ],
        ],
        const SizedBox(height: FatFishSpacing.s4),
        if (entries.isEmpty)
          Text(
            'Nadie ha ganado una partida todavía.',
            style: textTheme.bodyMedium?.copyWith(color: FatFishColors.fog400),
          )
        else
          // The page asked for loads behind the one on screen.
          AnimatedOpacity(
            opacity: state.loadingPage == null ? 1 : 0.5,
            duration: motionDuration(context, FatFishMotion.fast),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (podium.isNotEmpty) ...[
                  Podium(top: podium),
                  const SizedBox(height: FatFishSpacing.s4),
                ],
                if (rows.isNotEmpty)
                  RowsPanel(
                    children: [
                      for (final (index, entry) in rows.indexed)
                        Appear(
                          key: ValueKey('${ranking.page}-${entry.position}'),
                          delay: FatFishMotion.stagger * index,
                          child: RankingRow(entry),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        if (ranking.totalPages > 1) ...[
          const SizedBox(height: FatFishSpacing.s4),
          PageBar(
            current: state.loadingPage ?? ranking.page,
            total: ranking.totalPages,
            onPage: context.read<RankingCubit>().goToPage,
          ),
        ],
      ],
    );
  }
}

/// The house note that explains how the ranking orders the players.
class _RankingHelpNote extends StatelessWidget {
  const _RankingHelpNote();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Transform.rotate(
        angle: 0.012,
        child: RuledPaper(
          padding: const EdgeInsets.all(24),
          shadow: const [
            BoxShadow(color: FatFishColors.ink500, offset: Offset(0, 5)),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NOTA DE LA CASA',
                    style: TextStyle(
                      fontFamily: FatFishFonts.label,
                      fontSize: 7,
                      color: FatFishColors.ink900,
                    ),
                  ),
                  Text(
                    'RANKING',
                    style: TextStyle(
                      fontFamily: FatFishFonts.label,
                      fontSize: 7,
                      color: FatFishColors.ink900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      (constraints.maxWidth / 6).floor().clamp(1, 1000),
                      (_) => const SizedBox(
                        width: 3,
                        height: 2,
                        child: ColoredBox(color: FatFishColors.ink500),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '¿Cómo subir posiciones?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FatFishFonts.display,
                          fontSize: 32,
                          height: 1,
                          color: FatFishColors.ink900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Para entrar, gana una partida. Solo cuenta el mayor puntaje '
                        'en una victoria; no se suman tus partidas.\n\n'
                        'En empate, queda primero '
                        'quien lo consiguió antes.\n\n'
                        'Los puntos no son dinero. En el historial puedes ver '
                        'cuánto ganaste o perdiste en cada partida.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FatFishFonts.body,
                          fontSize: 20,
                          height: 1.25,
                          color: FatFishColors.ink900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -0.015,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: FatFishColors.ink500,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor: FatFishColors.paper100,
                        backgroundColor: FatFishColors.ink900,
                        minimumSize: const Size(156, 48),
                        side: BorderSide.none,
                        shape: const RoundedRectangleBorder(),
                        textStyle: const TextStyle(
                          fontFamily: FatFishFonts.display,
                          fontSize: 24,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendido'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
