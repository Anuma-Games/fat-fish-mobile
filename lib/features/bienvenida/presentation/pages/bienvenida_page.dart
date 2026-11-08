import 'package:fat_fish_mobile/core/navigation/app_routes.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/casino_background.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/game_icon.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/bienvenida/presentation/widgets/table_lamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

/// First screen without a saved player: the table under its lamp, the title of the game
/// and the two ways in, find your player or look at the world ranking.
class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage>
    with SingleTickerProviderStateMixin {
  /// Seconds since the screen opened; drives the lamp, the dust and the flickers.
  final _seconds = ValueNotifier(0.0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _seconds.value = elapsed.inMicroseconds / 1e6,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // With "reduce motion" the room stays still, with the lamp already on.
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_ticker.isActive) _ticker.stop();
      _seconds.value = _stillAt;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  /// A moment after the lamp turned on, between flickers, with dust in the beam.
  static const _stillAt = 5.0;

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CasinoBackground(
        child: Stack(
          children: [
            // Vignette: the room goes dark around the table.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.04),
                      radius: 0.75,
                      colors: [
                        FatFishLamp.room.withValues(alpha: 0),
                        FatFishLamp.room.withValues(alpha: 0.7),
                        FatFishLamp.room,
                      ],
                      stops: const [0.3, 0.85, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -12,
              right: -12,
              top: 0,
              height: 470,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ValueListenableBuilder(
                    valueListenable: _seconds,
                    builder: (context, seconds, _) =>
                        TableLamp(seconds: seconds),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                FatFishSpacing.s6,
                padding.top + 80,
                FatFishSpacing.s6,
                padding.bottom + 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ANUMA GAMES PRESENTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FatFishFonts.label,
                      fontSize: 9,
                      letterSpacing: 1,
                      color: FatFishColors.gold400,
                    ),
                  ),
                  const SizedBox(height: FatFishSpacing.s2),
                  ValueListenableBuilder(
                    valueListenable: _seconds,
                    builder: (context, seconds, child) => Opacity(
                      // Old screen flicker, every 7 s.
                      opacity: stepped((seconds % 7) / 7, const [
                        (0, 1),
                        (0.48, 0.8),
                        (0.49, 1),
                        (0.84, 0.9),
                        (0.85, 1),
                      ]),
                      child: child,
                    ),
                    child: const _Title(),
                  ),
                  const SizedBox(height: FatFishSpacing.s1),
                  Text(
                    'Una mesa. Cada ronda pide más. El casino siempre sabe de ti.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: FatFishColors.gold400,
                      height: 1.1,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ValueListenableBuilder(
                        valueListenable: _seconds,
                        builder: (context, seconds, _) =>
                            _TableIcon(seconds: seconds),
                      ),
                    ),
                  ),
                  Text(
                    'Busca tu jugador para ver lo que el casino anotó de ti',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: FatFishSpacing.s4),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(FatFishRadius.card),
                      boxShadow: FatFishShadows.hard,
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        textStyle: textTheme.labelLarge?.copyWith(fontSize: 24),
                      ),
                      onPressed: () => context.push(AppRoutes.jugador),
                      child: const Text('Buscar mi jugador'),
                    ),
                  ),
                  const SizedBox(height: FatFishSpacing.s3),
                  OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: Colors.transparent,
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontSize: 24,
                          ),
                        ).copyWith(
                          side: const WidgetStatePropertyAll(
                            BorderSide(color: FatFishColors.gold600, width: 2),
                          ),
                        ),
                    onPressed: () => context.go(AppRoutes.ranking),
                    child: const Text('Ver el ranking mundial'),
                  ),
                  const SizedBox(height: FatFishSpacing.s3),
                  Text(
                    'No necesitas cuenta ni contraseña. '
                    'Todo el dinero del juego es ficticio.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "FAT FISH" in big pixel letters, with the color fringes and scan lines of an old
/// screen and a hard shadow.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Fat Fish',
      excludeSemantics: true,
      child: CustomPaint(
        foregroundPainter: const _ScanLinesPainter(),
        child: Text(
          'FAT FISH',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontFamily: FatFishFonts.display,
            fontSize: 108,
            height: 0.82,
            letterSpacing: 0.5,
            color: FatFishColors.cream100,
            shadows: [
              Shadow(
                color: FatFishColors.red.withValues(alpha: 0.8),
                offset: const Offset(3, 0),
              ),
              Shadow(
                color: FatFishColors.gold400.withValues(alpha: 0.45),
                offset: const Offset(-3, 0),
              ),
              Shadow(
                color: FatFishLamp.light.withValues(alpha: 0.25),
                blurRadius: 40,
              ),
              const Shadow(color: Color(0xFF000000), offset: Offset(6, 6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark line every 4 px over the title, like the rows of a tube screen.
class _ScanLinesPainter extends CustomPainter {
  const _ScanLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = const Color(0x59000000);
    for (var y = 3.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }
  }

  @override
  bool shouldRepaint(_ScanLinesPainter oldDelegate) => false;
}

/// The game icon on the table, lit from above. It comes on with the lamp.
class _TableIcon extends StatelessWidget {
  const _TableIcon({required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context) {
    final light = seconds >= 1.6
        ? 1.0
        : stepped(seconds / 1.6, const [
            (0, 0.15),
            (0.12, 0.9),
            (0.18, 0.2),
            (0.30, 1),
            (0.36, 0.4),
            (0.50, 1),
          ]);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 248, maxHeight: 248),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0xFF000000), offset: Offset(6, 6)),
            ],
          ),
          child: GameIcon(brightness: 1.35 * light),
        ),
      ),
    );
  }
}
