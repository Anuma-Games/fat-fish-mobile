import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps [TableSound] in step with the settings and the app: it sounds when the player
/// turns it on, at their volume, and goes quiet while the app is in the background.
class SoundScope extends StatefulWidget {
  const SoundScope({super.key, required this.child});

  final Widget child;

  @override
  State<SoundScope> createState() => _SoundScopeState();
}

class _SoundScopeState extends State<SoundScope> {
  late final TableSound _sound = context.read<TableSound>();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: _sound.pause,
      onShow: _sound.resume,
    );
    _apply(context.read<SettingsCubit>().state);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _apply(Settings settings) => _sound.configure(
    ambience: settings.ambienceOn,
    effects: settings.tableSoundsOn,
    volume: settings.volume / Settings.maxVolume,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, Settings>(
      listenWhen: (previous, current) =>
          previous.ambienceOn != current.ambienceOn ||
          previous.tableSoundsOn != current.tableSoundsOn ||
          previous.volume != current.volume,
      listener: (context, settings) => _apply(settings),
      child: widget.child,
    );
  }
}
