import 'package:fat_fish_mobile/core/presentation/widgets/coming_soon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      appBar: const FatFishAppBar(title: 'Ranking'),
      body: const ComingSoon(
        eyebrow: 'Ranking',
        title: 'Ranking mundial',
        message: 'Aquí verás a los mejores jugadores y tu posición.',
      ),
    );
  }
}
