import 'package:fat_fish_mobile/core/presentation/widgets/coming_soon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:flutter/material.dart';

class JugadorPage extends StatelessWidget {
  const JugadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      appBar: const FatFishAppBar(title: 'Mi jugador'),
      body: const ComingSoon(
        eyebrow: 'Mi jugador',
        title: 'Elige tu jugador',
        message:
            'Aquí podrás elegir tu jugador o buscar a otros por alias o ID.',
      ),
    );
  }
}
