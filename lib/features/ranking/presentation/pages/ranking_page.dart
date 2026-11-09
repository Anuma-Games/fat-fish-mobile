import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/offline_notice.dart';
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
        Text(
          'Mejores puntajes',
          style: textTheme.headlineLarge?.copyWith(height: 1),
        ),
        if (firstPage) ...[
          const SizedBox(height: 6),
          Text(
            'Solo cuenta la mejor partida que ganaste. '
            'Si dos empatan, gana quien llegó primero.',
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
