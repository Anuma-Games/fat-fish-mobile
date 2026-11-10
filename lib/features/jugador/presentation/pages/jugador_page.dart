import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notice.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/add_recent_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_recent_players.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/remove_recent_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/search_players.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/player_search_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/recent_players_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/my_player_card.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_list_panel.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/widgets/player_row.dart';
import 'package:flutter/material.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/haptics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class JugadorPage extends StatelessWidget {
  const JugadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = context.read<PlayerRepository>();

    // Search and recents belong to this tab; MyPlayerCubit is app-wide (see AppProviders).
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PlayerSearchCubit(searchPlayers: SearchPlayers(players)),
        ),
        BlocProvider(
          create: (_) => RecentPlayersCubit(
            getRecentPlayers: GetRecentPlayers(players),
            addRecentPlayer: AddRecentPlayer(players),
            removeRecentPlayer: RemoveRecentPlayer(players),
          )..load(),
        ),
      ],
      child: const _JugadorView(),
    );
  }
}

/// How long the chosen row or card stays on screen, gold, before the dossier opens.
const _confirmPause = Duration(milliseconds: 350);

class _JugadorView extends StatefulWidget {
  const _JugadorView();

  @override
  State<_JugadorView> createState() => _JugadorViewState();
}

class _JugadorViewState extends State<_JugadorView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _query.clear();
    context.read<PlayerSearchCubit>().clear();
  }

  /// True from the tap until the dossier opens, so a second tap does nothing.
  bool _choosing = false;

  /// Chooses [player], lets the row or card turn gold for a moment and opens
  /// the dossier. The search is cleared on the way out, ready for the next visit.
  Future<void> _choose(PlayerSummary player) async {
    if (_choosing) return;
    _choosing = true;
    Haptics.selection(context);
    FocusScope.of(context).unfocus();
    final recents = context.read<RecentPlayersCubit>();
    final router = GoRouter.maybeOf(context);
    final pause = motionDuration(context, _confirmPause);

    final myPlayer = context.read<MyPlayerCubit>();

    try {
      await myPlayer.choose(player);
      await recents.add(player);
      await Future<void>.delayed(pause);
      if (!mounted) return;
      router?.go(AppRoutes.expediente);
      _clearSearch();
    } finally {
      _choosing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPlayerState = context.watch<MyPlayerCubit>().state;
    final myPlayer = switch (myPlayerState) {
      MyPlayerChosen(:final player) => player,
      _ => null,
    };
    final recents = context.watch<RecentPlayersCubit>().state;
    // Your player is already in the card, so the list shows only the others.
    final otherRecents = recents
        .where((recent) => recent.id != myPlayer?.id)
        .take(_recentShown)
        .toList();

    PlayerRowBadge badgeOf(PlayerSummary player) => switch (player.id) {
      final id when id == myPlayer?.id => PlayerRowBadge.mine,
      final id when recents.any((recent) => recent.id == id) =>
        PlayerRowBadge.recent,
      _ => PlayerRowBadge.none,
    };

    // Rows enter one after another. The key keeps a row that stays between two
    // searches still; only the new ones animate.
    Widget results(List<PlayerSummary> players) => PlayerListPanel(
      children: [
        for (final (index, player) in players.indexed)
          Appear(
            key: ValueKey(player.id),
            delay: FatFishMotion.stagger * index.clamp(0, 8),
            child: PlayerRow(
              player: player,
              highlight: _query.text.trim(),
              badge: badgeOf(player),
              onTap: () => _choose(player),
            ),
          ),
      ],
    );

    return Scaffold(
      // Plain background, so the field and the lists lead.
      backgroundColor: FatFishColors.bg900,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'Mi jugador'),
      // Under the Scaffold, whose MediaQuery counts the bar over the content.
      body: Builder(
        builder: (context) => ListView(
          padding: FatFishAppBar.pageInsets(context),
          // Scrolling the results hides the keyboard.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              '¿Quién eres en la mesa?',
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(height: 1),
            ),
            const SizedBox(height: 20),
            _SearchField(controller: _query, onClear: _clearSearch),
            const SizedBox(height: FatFishSpacing.s4),
            BlocBuilder<PlayerSearchCubit, PlayerSearchState>(
              builder: (context, state) => AnimatedSwitcher(
                duration: motionDuration(context, FatFishMotion.base),
                switchInCurve: FatFishMotion.curve,
                // Top aligned: the outgoing and incoming views start under the field.
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                // One key per view, not per state: Loading and Loaded are the same list.
                child: KeyedSubtree(
                  key: ValueKey(switch (state) {
                    PlayerSearchInitial() => 'home',
                    PlayerSearchLoading() || PlayerSearchLoaded() => 'results',
                    PlayerSearchEmpty() => 'empty',
                    PlayerSearchFailure() => 'failure',
                  }),
                  child: switch (state) {
                    PlayerSearchInitial() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Only with a player: without one, the question above
                        // already says what to do.
                        if (myPlayer != null)
                          MyPlayerCard(
                            player: myPlayer,
                            onClear: context.read<MyPlayerCubit>().clear,
                          ),
                        if (otherRecents.isNotEmpty)
                          _RecentPlayers(otherRecents, onChoose: _choose),
                      ],
                    ),
                    // The spinner lives in the search field, so the list never moves.
                    PlayerSearchLoading(:final players) => results(players),
                    PlayerSearchLoaded(:final players) => results(players),
                    PlayerSearchEmpty(:final query) => Notice(
                      icon: PixelIcons.search,
                      text: 'Nadie coincide con "$query".',
                    ),
                    PlayerSearchFailure(:final message) => Notice(
                      icon: PixelIcons.offline,
                      text: message,
                      color: FatFishColors.cream100,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onClear});

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerSearchCubit>();

    return TextField(
      controller: controller,
      maxLength: 24,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      onChanged: cubit.queryChanged,
      // Enter searches at once; `done` also hides the keyboard.
      onSubmitted: cubit.search,
      decoration: InputDecoration(
        hintText: 'Buscar por alias o ID',
        counterText: '',
        // Magnifier while empty, a spinner while searching and a button to
        // clear the text otherwise. All take the same 48 px and fade into each
        // other, so nothing jumps or pops.
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final loading = context.select(
              (PlayerSearchCubit cubit) => cubit.state is PlayerSearchLoading,
            );
            final Widget icon = switch ((controller.text.isEmpty, loading)) {
              (true, _) => const PixelIcon(
                PixelIcons.search,
                key: ValueKey('search'),
                size: 24,
                color: FatFishColors.fog400,
              ),
              (false, true) => const SizedBox.square(
                key: ValueKey('loading'),
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: FatFishColors.gold400,
                ),
              ),
              (false, false) => const PixelIcon(
                PixelIcons.close,
                key: ValueKey('clear'),
                size: 12,
                color: FatFishColors.fog400,
              ),
            };

            return IconButton(
              // Still clears while loading, so the player is never stuck.
              tooltip: controller.text.isEmpty ? null : 'Borrar búsqueda',
              onPressed: controller.text.isEmpty ? null : onClear,
              icon: AnimatedSwitcher(
                duration: motionDuration(context, FatFishMotion.fast),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween(begin: 0.6, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: icon,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Recent players shown under the card. The repository keeps one more ([recentLimit]),
/// so hiding your player still leaves this many.
const _recentShown = 5;

/// Recent players under the card; swiping a row away forgets it.
class _RecentPlayers extends StatelessWidget {
  const _RecentPlayers(this.players, {required this.onChoose});

  final List<PlayerSummary> players;
  final ValueChanged<PlayerSummary> onChoose;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecentPlayersCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FatFishSpacing.s6),
        // Section label on the page edge, over the panel, like the field and card.
        Text('RECIENTES', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: FatFishSpacing.s2),
        PlayerListPanel(
          children: [
            for (final player in players)
              Dismissible(
                key: ValueKey(player.id),
                onDismissed: (_) => cubit.remove(player.id),
                background: const _DismissBackground(Alignment.centerLeft),
                secondaryBackground: const _DismissBackground(
                  Alignment.centerRight,
                ),
                // Your previous player fades in here after you choose another one.
                child: Appear(
                  child: PlayerRow(
                    player: player,
                    badge: PlayerRowBadge.recent,
                    onTap: () => onChoose(player),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground(this.alignment);

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    // The panel clips it to its rounded corners.
    return Container(
      color: FatFishColors.red,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: FatFishSpacing.s4),
      child: const PixelIcon(
        PixelIcons.close,
        size: 12,
        color: FatFishColors.cream100,
      ),
    );
  }
}
