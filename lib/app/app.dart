import 'package:fat_fish_mobile/app/router.dart';
import 'package:fat_fish_mobile/app/theme/app_theme.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/app_bar_actions.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/widgets/top_bar_actions.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FatFishApp extends StatefulWidget {
  const FatFishApp({super.key});

  @override
  State<FatFishApp> createState() => _FatFishAppState();
}

Widget _topBarActions(BuildContext context, {required bool settings}) =>
    TopBarActions(settings: settings);

class _FatFishAppState extends State<FatFishApp> {
  // Created once per app, so hot reload and rebuilds keep the navigation state.
  // MyPlayerCubit comes from AppProviders, above this widget.
  late final MyPlayerCubit _myPlayer = context.read<MyPlayerCubit>();
  late final StreamListenable _playerChanges = StreamListenable(
    _myPlayer.stream,
  );
  late final GoRouter _router = buildRouter(_myPlayer, refresh: _playerChanges);

  @override
  void dispose() {
    _router.dispose();
    _playerChanges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fat Fish',
      debugShowCheckedModeBanner: false,
      theme: buildFatFishTheme(),
      routerConfig: _router,
      // Every top bar gets the sound and settings buttons.
      builder: (context, child) => AppBarActions(
        builder: _topBarActions,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
