import 'package:fat_fish_mobile/features/expediente/presentation/expediente_scope.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/historial_page.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fat_fish_mobile/app/app_shell.dart';
import 'package:fat_fish_mobile/app/fade_branch_container.dart';
import 'package:fat_fish_mobile/core/navigation/app_routes.dart';

/// One branch per tab, so each tab keeps its own navigation stack. Each branch has its
/// own navigator, so each one needs its own Sentry observer; routes are named for Sentry.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.expediente,
    observers: [SentryNavigatorObserver()],
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
            observers: [SentryNavigatorObserver()],
            routes: [
              // The dossier and its history share one Cubit, given above both pages.
              ShellRoute(
                observers: [SentryNavigatorObserver()],
                builder: (context, state, child) =>
                    ExpedienteScope(child: child),
                routes: [
                  GoRoute(
                    name: 'expediente',
                    path: AppRoutes.expediente,
                    builder: (context, state) => const ExpedientePage(),
                    routes: [
                      GoRoute(
                        name: 'historial',
                        path: 'historial',
                        builder: (context, state) => const HistorialPage(),
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
                name: 'ranking',
                path: AppRoutes.ranking,
                builder: (context, state) => const RankingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: [SentryNavigatorObserver()],
            routes: [
              GoRoute(
                name: 'jugador',
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
