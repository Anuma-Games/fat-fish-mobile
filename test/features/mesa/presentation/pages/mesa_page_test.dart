import 'dart:math' as math;

import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/pages/mesa_page.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/roulette_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes down what the table plays.
class _RecordingSound extends SilentTableSound {
  int launches = 0;
  int clicks = 0;
  final tones = <double>[];
  int falls = 0;
  final rolls = <double>[];
  int stops = 0;

  @override
  void launch() => launches++;

  @override
  void click(double strength, {double tone = 3000}) {
    clicks++;
    tones.add(tone);
  }

  @override
  void roll(double speed, double amongFrets) => rolls.add(speed);

  @override
  void stopRoll() => stops++;

  @override
  void fall() => falls++;
}

void main() {
  late _RecordingSound sound;

  setUp(() => sound = _RecordingSound());
  tearDown(
    () => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue(),
  );

  /// The number the seeded wheel picks on its first spin.
  int firstNumber(int seed) => Roulette.order[Roulette.pick(math.Random(seed))];

  Future<void> pumpMesa(WidgetTester tester, {bool still = false}) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: still);
    await tester.pumpWidget(
      RepositoryProvider<TableSound>.value(
        value: sound,
        child: MaterialApp(home: MesaPage(random: math.Random(7))),
      ),
    );
    await tester.pump();
  }

  /// Leaves the page, so its clock and the croupier's timers stop.
  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  testWidgets('spinning shows the number and color, and sounds the ball', (
    tester,
  ) async {
    await pumpMesa(tester);
    expect(find.text('Toca la ruleta\npara girarla...'), findsOneWidget);
    expect(
      find.text(
        'Esta ruleta es solo para divertirte,\nno cambia tu expediente.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('La bola corre…'), findsOneWidget);
    expect(sound.launches, 1);
    expect(sound.clicks, 0);
    // Tapping again during the spin does not release another ball or sound.
    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump(const Duration(milliseconds: 2100));
    expect(sound.launches, 1);
    expect(sound.clicks, 0); // The ball is still on the outer track.

    // Frame by frame, so the clicks follow the ball.
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final number = firstNumber(7);
    final color = Roulette.colorOf(number).name;
    final label = switch (color) {
      'red' => 'ROJO',
      'black' => 'NEGRO',
      _ => 'VERDE',
    };
    expect(find.text('$number'), findsOneWidget);
    expect(find.text(label), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(sound.clicks, greaterThan(20));
    // Light contacts on entering the frets, fuller ones later, wood on bounces.
    expect(sound.tones.first, inExclusiveRange(3300, 3600));
    expect(sound.tones.where((t) => t < 3000 && t > 2700), isNotEmpty);
    expect(sound.tones, contains(1700));
    expect(sound.rolls, isNotEmpty);
    expect(sound.rolls.first, greaterThan(sound.rolls.last));
    expect(sound.stops, greaterThanOrEqualTo(1));
    expect(sound.falls, 0);

    // The ball rides the head: it rests in its pocket wherever the head left it, not
    // always at the top.
    final wheel = tester.widget<RouletteWheel>(find.byType(RouletteWheel));
    final pocket = Roulette.order.indexOf(number);
    final pocketAt = wheel.head + pocket * Roulette.step + Roulette.step / 2;
    final ballOff = wheel.ball - pocketAt;
    expect((ballOff - ballOff.roundToDouble()).abs(), lessThan(1e-6));
    expect((wheel.ball % 1 - 0).abs(), greaterThan(0.01));

    await leave(tester);
  });

  for (final withSound in [true, false]) {
    testWidgets('landing haptic follows the final pocket (sound: $withSound)', (
      tester,
    ) async {
      final impacts = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            impacts.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      if (withSound) {
        await pumpMesa(tester);
      } else {
        await tester.pumpWidget(
          MaterialApp(home: MesaPage(random: math.Random(7))),
        );
      }
      await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
      await tester.pump();
      final pocket = Roulette.order.indexOf(firstNumber(7));
      var entered = false;
      var clicksAtLanding = 0;
      var rollsAtLanding = 0;
      for (var frame = 0; frame < 400; frame++) {
        final clicksBeforeFrame = sound.clicks;
        await tester.pump(const Duration(milliseconds: 16));
        final wheel = tester.widget<RouletteWheel>(find.byType(RouletteWheel));
        final center = wheel.head + pocket * Roulette.step + Roulette.step / 2;
        final offset = wheel.ball - center;
        final inFinalPocket =
            (offset - offset.roundToDouble()).abs() <= Roulette.step / 2 &&
            (wheel.ballRadius - RouletteWheel.pocketRadius).abs() < 1;
        final landed = impacts.contains('HapticFeedbackType.mediumImpact');
        if (!entered && landed) {
          expect(inFinalPocket, isTrue);
          expect(find.text('La bola corre…'), findsOneWidget);
          expect(sound.clicks - clicksBeforeFrame, withSound ? 1 : 0);
          if (withSound) expect(sound.tones.last, 2700);
          entered = true;
          clicksAtLanding = sound.clicks;
          rollsAtLanding = sound.rolls.length;
        } else if (!entered) {
          expect(inFinalPocket, isFalse);
        } else {
          expect(sound.clicks, clicksAtLanding);
          expect(sound.rolls.length, rollsAtLanding);
        }
      }
      expect(entered, isTrue);
      expect(
        impacts.where((s) => s == 'HapticFeedbackType.mediumImpact'),
        hasLength(1),
      );
      expect(sound.falls, 0);
      await leave(tester);
    });
  }

  testWidgets('a second spin moves the first number to the last ones', (
    tester,
  ) async {
    await pumpMesa(tester, still: true);
    final random = math.Random(7);
    final first = Roulette.order[Roulette.pick(random)];

    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump();

    expect(
      find.bySemanticsLabel(RegExp('^Últimos giros: $first, ')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('2 giros')), findsOneWidget);

    await leave(tester);
  });

  testWidgets(
    'with reduced motion the result shows at once, without the roll',
    (tester) async {
      await pumpMesa(tester, still: true);

      await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
      await tester.pump();

      expect(find.text('La bola corre…'), findsNothing);
      expect(find.text('${firstNumber(7)}'), findsOneWidget);
      expect(sound.clicks, 1);
      expect(sound.tones, [2700]);
      expect(sound.launches, 0);
      expect(sound.rolls, isEmpty);
      expect(sound.falls, 0);

      await leave(tester);
    },
  );

  testWidgets('counts the time of the visit', (tester) async {
    await pumpMesa(tester, still: true);

    await tester.pump(const Duration(seconds: 65));

    expect(find.text('1:05'), findsOneWidget);
    await leave(tester);
  });
}
