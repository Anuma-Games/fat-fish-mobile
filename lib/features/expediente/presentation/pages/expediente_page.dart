import 'package:fat_fish_mobile/core/presentation/widgets/coming_soon.dart';
import 'package:flutter/material.dart';

class ExpedientePage extends StatelessWidget {
  const ExpedientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Expediente')),
      body: const ComingSoon(
        title: 'Lo que el casino sabe de ti',
        message: 'Aquí verás tu expediente y el historial de tus partidas.',
      ),
    );
  }
}
