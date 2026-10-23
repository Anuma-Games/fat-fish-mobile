import 'package:fat_fish_mobile/core/presentation/widgets/casino_background.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Casino background and bottom navigation around the three tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CasinoBackground(child: navigationShell),
      // Gold top border, like the bottom border of the app bar.
      bottomNavigationBar: DecoratedBox(
        // In front: NavigationBar paints its own background over a back decoration.
        position: DecorationPosition.foreground,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: FatFishColors.gold600, width: 2),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          // Tapping the current tab again returns it to its first screen.
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: PixelIcon(PixelIcons.dossier),
              label: 'EXPEDIENTE',
            ),
            NavigationDestination(
              icon: PixelIcon(PixelIcons.ranking),
              label: 'RANKING',
            ),
            NavigationDestination(
              icon: PixelIcon(PixelIcons.player),
              label: 'MI JUGADOR',
            ),
          ],
        ),
      ),
    );
  }
}
