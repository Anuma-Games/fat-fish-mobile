import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Speaker that turns the sound on and off, cream while it sounds and grey when it does
/// not, and the gear that opens Ajustes.
class TopBarActions extends StatelessWidget {
  const TopBarActions({super.key, this.settings = true});

  /// False on Ajustes, where the gear would open the same screen.
  final bool settings;

  @override
  Widget build(BuildContext context) {
    final ambienceOn = context.select(
      (SettingsCubit cubit) => cubit.state.ambienceOn,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          toggled: ambienceOn,
          child: IconButton(
            tooltip: ambienceOn
                ? 'Apagar el ambiente de fondo'
                : 'Encender el ambiente de fondo',
            onPressed: context.read<SettingsCubit>().toggleAmbience,
            icon: PixelIcon(
              ambienceOn ? PixelIcons.sound : PixelIcons.mute,
              color: ambienceOn ? FatFishColors.cream100 : FatFishColors.fog400,
            ),
          ),
        ),
        if (settings)
          IconButton(
            tooltip: 'Ajustes',
            onPressed: () => context.push(AppRoutes.ajustes),
            icon: const PixelIcon(
              PixelIcons.gear,
              color: FatFishColors.cream100,
            ),
          ),
      ],
    );
  }
}
