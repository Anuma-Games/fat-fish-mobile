import 'package:fat_fish_mobile/core/presentation/widgets/coming_soon.dart';
import 'package:flutter/material.dart';

class JugadorPage extends StatelessWidget {
  const JugadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi jugador')),
      body: const ComingSoon(
        title: 'Mi jugador',
        message:
            'Aquí podrás elegir tu jugador o buscar a otros por alias o ID.',
      ),
    );
  }
}
