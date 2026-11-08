import 'package:fat_fish_mobile/core/presentation/widgets/coming_soon.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:flutter/material.dart';

/// The table tab. The decorative roulette arrives with its own ticket; until then the
/// tab says what will be here.
class MesaPage extends StatelessWidget {
  const MesaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the casino pattern of AppShell shows through.
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'La mesa'),
      // Under the Scaffold, whose MediaQuery counts the bar over the content.
      body: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: const ComingSoon(
            eyebrow: 'La mesa',
            title: 'Toma asiento',
            message: 'Muy pronto: una ruleta para girar mientras esperas.',
          ),
        ),
      ),
    );
  }
}
