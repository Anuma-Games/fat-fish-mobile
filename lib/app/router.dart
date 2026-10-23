import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';

/// Paths shared by the router and the features.
abstract final class AppRoutes {
  static const expediente = '/expediente';
  static const ranking = '/ranking';
  static const jugador = '/jugador';
}

/// One branch per tab, so each tab keeps its own navigation stack.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.expediente,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expediente,
                builder: (context, state) => const ExpedientePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ranking,
                builder: (context, state) => const RankingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.jugador,
                builder: (context, state) => const JugadorPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
