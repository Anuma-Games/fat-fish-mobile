import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/entities/settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/widgets/pixel_switch.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/widgets/volume_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sound, vibration and what the app is, with the help line for gambling problems.
class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key, this.call = launchUrl});

  /// Opens the phone at a number; tests pass one that cannot.
  final Future<bool> Function(Uri) call;

  /// Línea de la Vida, the national help line of Mexico (free, 24 hours).
  static final helpLine = Uri(scheme: 'tel', path: '8009112000');

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    return Scaffold(
      // Plain background, so the controls lead.
      backgroundColor: FatFishColors.bg900,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'Ajustes', settings: false),
      // Under the Scaffold, whose MediaQuery counts the bar over the content.
      body: Builder(
        builder: (context) => ListView(
          // 12 px at the sides, as in the design: the panels reach further.
          padding: FatFishAppBar.pageInsets(context)
              .copyWith(left: FatFishSpacing.s3, right: FatFishSpacing.s3),
          children: [
            const _SectionTitle('SONIDO'),
            _Panel(
              children: [
                // The design's background music; here the room of the PWA plays.
                _SwitchRow(
                  title: 'Ambiente de fondo',
                  detail:
                      'El cuarto y el zumbido de la lámpara en bucle mientras '
                      'navegas.',
                  value: settings.ambienceOn,
                  onChanged: (_) => cubit.toggleAmbience(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          'Volumen',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: VolumeBar(
                          value: settings.volume,
                          levels: Settings.maxVolume,
                          active: settings.ambienceOn || settings.tableSoundsOn,
                          onChanged: cubit.setVolume,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: ExcludeSemantics(
                          child: Text(
                            '${settings.volume * 100 ~/ Settings.maxVolume} %',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: FatFishColors.cream100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                _SwitchRow(
                  title: 'Sonidos de la mesa',
                  detail: 'Clics de la bola y caída en la casilla.',
                  value: settings.tableSoundsOn,
                  onChanged: (_) => cubit.toggleTableSounds(),
                ),
                const Divider(height: 1, thickness: 1),
                _SwitchRow(
                  title: 'Vibración',
                  detail: 'Al cambiar de pestaña y al caer la bola.',
                  value: settings.vibration,
                  onChanged: (_) => cubit.toggleVibration(),
                ),
              ],
            ),
            const SizedBox(height: FatFishSpacing.s6),
            const _SectionTitle('ACERCA DE'),
            _About(call: call),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FatFishSpacing.s2),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: FatFishColors.bg700,
        border: Border.fromBorderSide(BorderSide(color: FatFishColors.line)),
        borderRadius: BorderRadius.all(FatFishRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(detail, style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: FatFishSpacing.s3),
            PixelSwitch(value: value, label: title, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.call});

  final Future<bool> Function(Uri) call;

  /// Opens the phone; a device that cannot call (a tablet) shows the number instead.
  Future<void> _call(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await call(AjustesPage.helpLine);
    } on Object {
      opened = false;
    }
    if (opened) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Llama a la Línea de la Vida: 800 911 2000'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _Panel(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      'Fat Fish',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) => Text(
                      snapshot.hasData
                          ? 'v${snapshot.data!.version}, Anuma Games'
                          : 'Anuma Games',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Todo el dinero del juego es ficticio. Si apostar deja de ser un '
                'juego, pide ayuda.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => _call(context),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: FatFishColors.gold400,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            textStyle: const TextStyle(
              fontFamily: FatFishFonts.body,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const PixelIcon(PixelIcons.phone, color: FatFishColors.gold400),
          label: const Text('Línea de la Vida: 800 911 2000'),
        ),
      ],
    );
  }
}
