import 'dart:async';
import 'dart:math' as math;

import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/fat_fish_app_bar.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/notched_box.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/haptics.dart';
import 'package:fat_fish_mobile/features/mesa/domain/croupier.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/croupier_line.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/pocket_colors.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/roulette_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The table tab: a roulette to spin while waiting, with the croupier, the spins and
/// time of this visit and the last numbers. Only for fun: it changes nothing in the
/// dossier.
class MesaPage extends StatefulWidget {
  const MesaPage({super.key, this.random});

  /// Source of the numbers and the croupier's lines; tests pass a seeded one.
  final math.Random? random;

  /// As long as a tap on the wheel of the PWA.
  static const spinDuration = Duration(milliseconds: 5800);

  /// Size of the design: the scene scales down to fit smaller screens.
  static const _scene = Size(390, 670);

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> with TickerProviderStateMixin {
  late final math.Random _random = widget.random ?? math.Random();
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: MesaPage.spinDuration,
  )..addListener(_onFrame);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  /// The head always turns slowly, as in the PWA; while it waits for the first spin the
  /// ball also runs the track. Muted on another tab and with reduced motion.
  late final Ticker _idle = createTicker(_onIdle);
  Duration _idleLast = Duration.zero;

  /// Repaints the wheel on every idle frame without building the rest of the page.
  final _wheelFrame = ValueNotifier(0);
  final _pacer = ClickPacer();
  late final AppLifecycleListener _lifecycle;
  Timer? _clock;

  /// One slow turn of the head, in seconds.
  static const _idleTurn = 80.0;

  /// Speed of the ball on the track before the first spin, in turns per second.
  static const _idleBall = 24 / 360;

  /// Turns the head gains with each spin (600° in the PWA).
  static const _impulse = 600 / 360;

  // The head turns by itself ([_drift]) and from each spin ([_impulseFrom] to
  // [_impulseTo]). The ball lives in the frame of the head: from [_ballFrom] to
  // [_ballTo] it runs the other way, falls and rides the head in its pocket, so it
  // lands anywhere around the table.
  double _drift = 0;
  double _impulseFrom = 0;
  double _impulseTo = 0;
  double _ballFrom = 0;
  double _ballTo = 0;
  double _radiusFrom = RouletteWheel.trackRadius;
  bool _inPocket = false;
  int? _pick;

  // Sound of the frame before, to pace the clicks and the roll.
  double _lastProgress = 0;
  double _lastBall = 0;
  // Radius of the ball two frames back and one frame back, to hear each bounce.
  double _radiusBefore = 0;
  double _radiusPrevious = 0;

  int _line = Croupier.greeting;
  int _lineSerial = 0;
  int _spins = 0;
  int _seconds = 0;
  bool _appVisible = true;
  bool _tabVisible = true;
  bool _still = false;

  /// Numbers of this visit, newest first; the first is the current result.
  final _history = <int>[];

  bool get _spinning => _spin.isAnimating;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _appVisible = false,
      onShow: () => _appVisible = true,
    );
    // The time of the visit counts while the table is on screen.
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_appVisible && _tabVisible) setState(() => _seconds++);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sound = _findSound();
    _still = MediaQuery.disableAnimationsOf(context);
    _tabVisible = TickerMode.valuesOf(context).enabled;
    // Another tab pauses the spin; its roll must not keep sounding there.
    if (!_tabVisible) _sound?.stopRoll();
    if (_still) {
      _idle.stop();
    } else if (!_idle.isActive) {
      _idleLast = Duration.zero;
      unawaited(_idle.start());
    }
    _updatePulse();
  }

  /// Kept from [didChangeDependencies]: [dispose] can no longer look it up.
  TableSound? _sound;

  TableSound? _findSound() {
    try {
      return context.read<TableSound>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  void dispose() {
    _sound?.stopRoll();
    _clock?.cancel();
    _lifecycle.dispose();
    _idle.dispose();
    _spin.dispose();
    _pulse.dispose();
    _wheelFrame.dispose();
    super.dispose();
  }

  /// The invitation pulses until the first spin, unless motion is reduced.
  void _updatePulse() {
    if (_still || _spins > 0 || _spinning) {
      _pulse
        ..stop()
        ..value = 0;
    } else if (!_pulse.isAnimating) {
      unawaited(_pulse.repeat(reverse: true));
    }
  }

  void _onIdle(Duration elapsed) {
    // A long gap (another tab, the background) does not jump the wheel.
    final seconds = math.min(0.1, (elapsed - _idleLast).inMicroseconds / 1e6);
    _idleLast = elapsed;
    if (seconds <= 0) return;
    _drift += seconds / _idleTurn;
    if (!_spinning && !_inPocket) {
      _ballFrom -= _idleBall * seconds;
      _ballTo = _ballFrom;
    }
    _wheelFrame.value++;
  }

  double get _progress => _spinning || _pick != null ? _spin.value : 0;

  /// Ease out like the PWA: fast at the throw, slow at the end.
  double get _eased => 1 - math.pow(1 - _progress, 3).toDouble();

  double get _head =>
      _drift + _impulseFrom + (_impulseTo - _impulseFrom) * _eased;

  /// Angle of the ball in the frame of the head, before the hops over the frets.
  double get _ballInHead => _ballFrom + (_ballTo - _ballFrom) * _eased;

  /// Where the ball is across its pocket: 0 at the center, 0.5 on the fret.
  double get _acrossPocket {
    final x = (_ballInHead - _ballTo) / Roulette.step;
    return x - x.floorToDouble();
  }

  /// Among the pockets the ball lingers in each one and hops the fret, as in the PWA.
  double get _hop {
    if (!_spinning) return 0;
    final among = _smooth(0.55, 0.75, _progress);
    final f = _acrossPocket;
    return (Roulette.fretHop(f) - f) * Roulette.step * among;
  }

  double get _lift {
    if (!_spinning) return 0;
    final among = _smooth(0.55, 0.75, _progress);
    return among *
        math.pow(math.sin(math.pi * _acrossPocket), 4) *
        math.min(1, (1 - _progress) * 4);
  }

  static double _smooth(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  /// The ball climbs out of its pocket to the track, runs it, falls bouncing among
  /// the frets and settles.
  double get _ballRadius {
    const track = RouletteWheel.trackRadius;
    const pocket = RouletteWheel.pocketRadius;
    if (!_spinning) return _inPocket ? pocket : track;
    final k = _progress;
    if (k < 0.1) return _radiusFrom + (track - _radiusFrom) * (k / 0.1);
    if (k < 0.5) return track;
    if (k < 0.75) {
      final u = (k - 0.5) / 0.25;
      return track -
          (track - pocket) * u +
          6 * math.sin(u * math.pi * 3) * (1 - u);
    }
    // Small bounces inside the pocket, as in the PWA.
    return pocket + 3 * math.sin((k - 0.75) * 50) * (1 - k);
  }

  void _onSpin() {
    if (_spinning) return;
    final pick = Roulette.pick(_random);
    final ballFrom = _ballInHead % 1;
    _radiusFrom = _ballRadius;
    _impulseFrom = (_impulseFrom + (_impulseTo - _impulseFrom) * _eased) % 1;
    _impulseTo = _impulseFrom + _impulse;
    _ballFrom = ballFrom;
    _ballTo = Roulette.ballTarget(ballFrom, pick);
    _pick = pick;
    _pacer.reset();
    _lastProgress = 0;
    _lastBall = _ballFrom;
    _radiusBefore = _radiusFrom;
    _radiusPrevious = _radiusFrom;
    Haptics.light(context);

    if (_still) {
      _spin.value = 1;
      _finish();
      return;
    }
    _spin.value = 0;
    setState(() {});
    _updatePulse();
    unawaited(_spin.forward(from: 0).whenComplete(_finish));
  }

  /// Clicks of the ball against the frets and its roll, paced like the PWA.
  void _onFrame() {
    final sound = _sound;
    if (sound == null || !_spinning) return;
    final k = _progress;
    final seconds =
        (k - _lastProgress) * MesaPage.spinDuration.inMicroseconds / 1e6;
    if (seconds <= 0) return;
    final ball = _ballInHead;
    final frets = (ball - _lastBall) / seconds * Roulette.pockets;
    _lastProgress = k;
    _lastBall = ball;

    // On the track the clicks are fast, light and high; among the frets louder, deeper
    // and further apart, as in the PWA.
    final amongFrets = ClickPacer.amongFrets(k);
    sound.roll(ClickPacer.speedAt(k), amongFrets);
    final clicks = _pacer.advance(
      progress: k,
      seconds: seconds,
      fretsPerSecond: frets,
    );
    final strength = 0.28 + 0.72 * amongFrets;
    final tone = 3600 - 900 * amongFrets;
    for (var i = 0; i < clicks; i++) {
      sound.click(strength * (0.7 + 0.3 * _random.nextDouble()), tone: tone);
    }

    // Each bounce touches down with a deeper knock.
    final radius = _ballRadius;
    if (k > 0.5 &&
        _radiusPrevious < _radiusBefore &&
        radius > _radiusPrevious) {
      sound.click(0.5 + 0.4 * amongFrets, tone: 1700);
    }
    _radiusBefore = _radiusPrevious;
    _radiusPrevious = radius;
  }

  void _finish() {
    if (!mounted || _spin.value < 1) return;
    final number = Roulette.order[_pick!];
    _sound
      ?..stopRoll()
      ..fall();
    Haptics.medium(context);
    setState(() {
      _inPocket = true;
      _spins++;
      _history.insert(0, number);
      if (_history.length > 6) _history.removeLast();
      _line = Croupier.next(_random, _line);
      _lineSerial++;
    });
    _updatePulse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FatFishColors.bg900,
      extendBodyBehindAppBar: true,
      appBar: const FatFishAppBar(title: 'La mesa'),
      // Under the Scaffold, whose MediaQuery counts the bars over the content.
      body: Builder(
        builder: (context) {
          final padding = MediaQuery.paddingOf(context);
          return Stack(
            children: [
              Positioned(
                top: padding.top,
                left: 0,
                right: 0,
                height: 460,
                child: const _Photo(),
              ),
              Positioned.fill(
                top: padding.top,
                bottom: padding.bottom,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox.fromSize(
                    size: MesaPage._scene,
                    child: _scene(context),
                  ),
                ),
              ),
              Positioned(
                top: padding.top + FatFishSpacing.s2,
                left: FatFishSpacing.s4,
                right: FatFishSpacing.s4,
                child: Center(
                  // As wide as the design at most: a long line wraps.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 358),
                    child: CroupierLine(
                      text: Croupier.lines[_line],
                      serial: _lineSerial,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scene(BuildContext context) {
    final result = _spinning || _history.isEmpty ? null : _history.first;

    return Stack(
      children: [
        Positioned(
          top: 178,
          left: 40,
          width: 310,
          height: 300,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              // Negative, like CSS perspective(800px): the far edge shrinks.
              ..setEntry(3, 2, -1 / 800)
              ..rotateX(38 * math.pi / 180),
            child: Center(
              child: Semantics(
                button: true,
                label: 'Girar la ruleta',
                onTap: _onSpin,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: _onSpin,
                  child: ListenableBuilder(
                    listenable: Listenable.merge([_spin, _wheelFrame]),
                    builder: (context, _) => RouletteWheel(
                      head: _head,
                      ball: _head + _ballInHead + _hop,
                      ballRadius: _ballRadius,
                      lift: _lift,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 494,
          left: 0,
          right: 0,
          height: 52,
          child: Center(child: _status(result)),
        ),
        Positioned(
          top: 493,
          left: 18,
          child: _Stats(spins: _spins, seconds: _seconds),
        ),
        Positioned(
          top: 493,
          left: 316,
          width: 64,
          child: _Recent(numbers: _history.skip(1).take(5).toList()),
        ),
        const Positioned(
          top: 610,
          left: 0,
          right: 0,
          child: Text(
            'Esta ruleta es solo para divertirte,\nno cambia tu expediente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FatFishFonts.body,
              fontSize: 12,
              height: 1.4,
              color: FatFishColors.fog400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _status(int? result) {
    const invitation = TextStyle(
      fontFamily: FatFishFonts.display,
      fontSize: 26,
      height: 1.1,
      color: FatFishColors.gold400,
    );

    if (_spinning) {
      return const Text('La bola corre…', style: invitation);
    }
    if (result == null) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: 1.08,
        ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
        child: const Text(
          'Toca la ruleta\npara girarla...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FatFishFonts.display,
            fontSize: 26,
            height: 1.1,
            color: FatFishColors.gold400,
            shadows: [Shadow(offset: Offset(2, 2))],
          ),
        ),
      );
    }

    final color = Roulette.colorOf(result);
    return Semantics(
      liveRegion: true,
      label: '$result, ${color.label}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(offset: Offset(3, 3))],
            ),
            child: NotchedBox(
              width: 48,
              height: 44,
              color: color.box,
              border: FatFishColors.gold400,
              child: Text('$result', style: _number(30)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            color.label.toUpperCase(),
            style: const TextStyle(
              fontFamily: FatFishFonts.label,
              fontSize: 9,
              letterSpacing: 1,
              color: FatFishColors.cream100,
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _number(double size) => TextStyle(
  fontFamily: FatFishFonts.display,
  fontSize: size,
  height: 1,
  color: FatFishColors.cream100,
);

const _caption = TextStyle(
  fontFamily: FatFishFonts.label,
  fontSize: 7,
  letterSpacing: 1,
  color: FatFishColors.fog400,
);

class _Photo extends StatelessWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/mesa.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(-0.24, -0.4),
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                FatFishColors.bg900,
                Color(0x8C0B1416),
                Color(0x590B1416),
                FatFishColors.bg900,
              ],
              stops: [0, 0.28, 0.55, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.spins, required this.seconds});

  final int spins;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

    return Semantics(
      label: 'Esta visita a la mesa: $spins giros, $clock de tiempo',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GIROS', style: _caption),
          const SizedBox(height: 4),
          Text('$spins', style: _number(26)),
          const SizedBox(height: 14),
          const Text('TIEMPO', style: _caption),
          const SizedBox(height: 4),
          Text(clock, style: _number(26)),
        ],
      ),
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent({required this.numbers});

  /// Spins before the current one, newest first.
  final List<int> numbers;

  @override
  Widget build(BuildContext context) {
    final described = numbers.isEmpty
        ? 'Sin giros anteriores'
        : numbers.map((n) => '$n, ${Roulette.colorOf(n).label}').join('; ');

    return Semantics(
      label: 'Últimos giros: $described',
      excludeSemantics: true,
      child: Column(
        children: [
          const Text('ÚLTIMOS', style: _caption),
          const SizedBox(height: 6),
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(height: 3),
            NotchedBox(
              width: 30,
              height: 28,
              border: FatFishColors.cream100.withAlpha(64),
              color: i < numbers.length
                  ? Roulette.colorOf(numbers[i]).box
                  : FatFishColors.bg900,
              child: i < numbers.length
                  ? Text('${numbers[i]}', style: _number(20))
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
