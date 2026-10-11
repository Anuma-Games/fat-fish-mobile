import 'package:flutter/material.dart';

import 'theme.dart';

/// Placeholder home screen until the dossier and ranking screens exist.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fat Fish')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lo que el casino sabe de ti',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Aquí podrás consultar tu expediente y el ranking mundial.',
              style: textTheme.bodyLarge?.copyWith(color: FatFishColors.fog),
            ),
          ],
        ),
      ),
    );
  }
}
