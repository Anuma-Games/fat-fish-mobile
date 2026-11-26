import 'dart:async';

import 'package:fat_fish_mobile/app/app_shell.dart';
import 'package:fat_fish_mobile/app/fade_branch_container.dart';
import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/pages/ajustes_page.dart';
import 'package:fat_fish_mobile/features/bienvenida/presentation/pages/bienvenida_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/expediente_scope.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/historial_page.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/pages/mesa_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Three tabs (dossier, table and ranking), each one a branch with its own navigation
/// stack, plus the welcome and the search over them. Each navigator needs its own Sentry
/// observer; routes are named for Sentry.
///
/// The dossier needs a saved player: without one, it goes to the welcome screen, and
/// the welcome goes to the dossier as soon as there is one.
GoRouter buildRouter(MyPlayerCubit myPlayer, {required Listenable refresh}) {
  return GoRouter(
    initialLocation: AppRoutes.expediente,
    observers: [SentryNavigatorObserver()],
    refreshListenable: refresh,
    redirect: (context, state) => switch (myPlayer.state) {
      // Reading the device takes a moment; the dossier shows nothing meanwhile.
      MyPlayerLoading() => null,
      MyPlayerNone()
          when state.matchedLocation.startsWith(AppRoutes.expediente) =>
        AppRoutes.bienvenida,
      MyPlayerChosen() when state.matchedLocation == AppRoutes.bienvenida =>
        AppRoutes.expediente,
      _ => null,
    },
    routes: [
      GoRoute(
        name: 'bienvenida',
        path: AppRoutes.bienvenida,
        pageBuilder: (context, state) =>
            _nativePage(state, const BienvenidaPage()),
      ),
      GoRoute(
        name: 'ajustes',
        path: AppRoutes.ajustes,
        pageBuilder: (context, state) =>
            _nativePage(state, const AjustesPage()),
      ),
      GoRoute(
        name: 'jugador',
        path: AppRoutes.jugador,
        pageBuilder: (context, state) =>
            _nativePage(state, const JugadorPage()),
      ),
      StatefulShellRoute(
        pageBuilder: (context, state, navigationShell) =>
            _nativePage(state, AppShell(navigationShell: navigationShell)),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            FadeBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            observers: [SentryNavigatorObserver()],
            routes: [
              // The dossier and its history share one Cubit, given above both pages.
              ShellRoute(
                observers: [SentryNavigatorObserver()],
                pageBuilder: (context, state, child) =>
                    _nativePage(state, ExpedienteScope(child: child)),
                routes: [
                  GoRoute(
                    name: 'expediente',
                    path: AppRoutes.expediente,
                    pageBuilder: (context, state) =>
                        _nativePage(state, const ExpedientePage()),
                    routes: [
                      GoRoute(
                        name: 'historial',
                        path: 'historial',
                        pageBuilder: (context, state) =>
                            _nativePage(state, const HistorialPage()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            observers: [SentryNavigatorObserver()],
            routes: [
              GoRoute(
                name: 'mesa',
                path: AppRoutes.mesa,
                pageBuilder: (context, state) =>
                    _nativePage(state, const MesaPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: [SentryNavigatorObserver()],
            routes: [
              GoRoute(
                name: 'ranking',
                path: AppRoutes.ranking,
                pageBuilder: (context, state) =>
                    _nativePage(state, const RankingPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Use the same MaterialPage class as this app's MaterialApp explicitly. The
// router's automatic adapter can otherwise fall back to NoTransitionPage when
// its Material package and the app's SDK Material widgets have different types.
// Keeping standard platform routes preserves iOS interactive back/cancellation
// and Android back handling; a drag detector around the screen would not.
MaterialPage<void> _nativePage(GoRouterState state, Widget child) =>
    MaterialPage<void>(
      key: state.pageKey,
      name: state.name ?? state.path,
      arguments: <String, String>{
        ...state.pathParameters,
        ...state.uri.queryParameters,
      },
      restorationId: state.pageKey.value,
      child: child,
    );

/// Tells the router to run its redirect again every time [stream] emits.
/// Its owner disposes it, since GoRouter does not.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
