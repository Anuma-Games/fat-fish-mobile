import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:go_router/go_router.dart';

import 'package:fat_fish_mobile/app/app_shell.dart';
import 'package:fat_fish_mobile/app/fade_branch_container.dart';
import 'package:fat_fish_mobile/core/navigation/app_routes.dart';

/// One branch per tab, so each tab keeps its own navigation stack.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.expediente,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            FadeBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
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
